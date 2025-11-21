import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import Stripe from 'stripe';

import { AppConfigService } from '../config/app-config.service';
import { PlansService } from '../plans/plans.service';
import { SubscriptionService } from '../subscription/subscription.service';
import { UserService } from '../user/user.service';
import { PaymentLog } from './entities/payment-log.entity';
import { Subscription } from '../subscription/entities/subscription.entity';
import { User } from '../user/entities/user.entity'; // Import User
import { Plan } from '../plans/entities/plan.entity'; // Import Plan

@Injectable()
export class PaymentsService {
  private stripe: Stripe;

  constructor(
    @InjectRepository(PaymentLog)
    private readonly paymentLogRepository: Repository<PaymentLog>,
    private readonly configService: AppConfigService,
    private readonly plansService: PlansService,
    private readonly subscriptionService: SubscriptionService,
    private readonly userService: UserService,
  ) {
    // Corrigido: Inicializa o Stripe com a chave secreta correta
    this.stripe = new Stripe(this.configService.STRIPE_SECRET_KEY, {
      apiVersion: '2024-04-10',
    });
  }

  /**
   * Cria uma sessao de checkout do Stripe para um plano especifico.
   */
  async createCheckoutSession(userId: string, planId: string): Promise<{ url: string }> {
    const plan = await this.plansService.findOne(planId);
    if (!plan || !plan.paymentGatewayId) {
      throw new BadRequestException('Plano nao encontrado ou nao configurado para pagamento.');
    }

    const user = await this.userService.findOne(userId);
    if (!user) {
      throw new BadRequestException('Usuario nao encontrado.');
    }

    // (O campo stripeCustomerId deve ser adicionado a UserEntity)
    const stripeCustomerId = null; // Placeholder (user.stripeCustomerId)

    const session = await this.stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      mode: 'subscription',
      line_items: [
        {
          price: plan.paymentGatewayId,
          quantity: 1,
        },
      ],
      customer: stripeCustomerId,
      customer_email: !stripeCustomerId ? user.email : undefined,
      
      // Corrigido: Usa a CLIENT_URL do AppConfigService
      success_url: `${this.configService.CLIENT_URL}/payment-success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${this.configService.CLIENT_URL}/payment-canceled`,
      
      metadata: {
        internalUserId: userId,
        internalPlanId: planId,
      },
    });

    if (!session.url) {
      throw new BadRequestException('Nao foi possivel criar a sessao de checkout.');
    }

    return { url: session.url };
  }

  /**
   * Manipulador de Webhooks do Stripe.
   */
  async handleStripeWebhook(signature: string, rawBody: Buffer) {
    // Corrigido: Usa o Webhook Secret do AppConfigService
    const webhookSecret = this.configService.STRIPE_WEBHOOK_SECRET;
    let event: Stripe.Event;

    try {
      event = this.stripe.webhooks.constructEvent(rawBody, signature, webhookSecret);
    } catch (err) {
      throw new BadRequestException(`Webhook Error: ${err.message}`);
    }

    // Handle the event
    switch (event.type) {
      case 'checkout.session.completed':
        const session = event.data.object as Stripe.Checkout.Session;
        // Logica para criar/atualizar a assinatura no nosso DB
        await this.fulfillCheckoutSession(session);
        break;
      
      // ... handle other event types
      default:
        console.log(`Unhandled event type ${event.type}`);
    }

    return { received: true };
  }

  /**
   * Logica de negocio chamada quando um checkout e concluido.
   * Cria/Atualiza a Assinatura e o Status (Role) do Usuario.
   */
  private async fulfillCheckoutSession(session: Stripe.Checkout.Session) {
    const userId = session.metadata.internalUserId;
    const planId = session.metadata.internalPlanId;
    const gatewaySubscriptionId = session.subscription as string;
    
    const user = await this.userService.findOne(userId);
    const plan = await this.plansService.findOne(planId);

    if (!user || !plan) {
      throw new BadRequestException('Usuario ou Plano nao encontrado durante o webhook.');
    }

    // (Logica de data de expiracao deve ser extraida do objeto 'subscription' do Stripe)
    const periodEnd = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000); // Placeholder 30 dias

    // 1. Atualiza/Cria a Assinatura
    await this.subscriptionService.createOrUpdateSubscription(
      user,
      plan.id,
      gatewaySubscriptionId,
      periodEnd,
      'active', // Status
      plan.grantedRole, // Role concedida
    );

    // 2. Atualiza o Role do Usuario
    await this.userService.updateUserRole(userId, plan.grantedRole);
    
    // 3. Logar o pagamento (opcional, mas recomendado)
    // ... (logica para salvar no PaymentLog)
  }

  /**
   * Retorna o status de assinatura do usuario logado.
   */
  async getSubscriptionStatus(userId: string): Promise<Subscription> {
    return this.subscriptionService.findByUserId(userId);
  }
}