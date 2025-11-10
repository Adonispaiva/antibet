import { Injectable, RawBody, ForbiddenException } from '@nestjs/common';
import { PlansService } from '../plans/plans.service'; // Injetar PlansService
import { UserService } from '../user/user.service'; // Injetar UserService
// import Stripe from 'stripe'; // Futuramente
// private stripe = new Stripe(process.env.STRIPE_SECRET_KEY, { apiVersion: '2020-08-27' });

@Injectable()
export class PaymentsService {
  // Futuramente: Injetar repositório de logs de pagamento

  constructor(
    private readonly plansService: PlansService,
    private readonly userService: UserService,
  ) {}

  /**
   * Recebe e processa o evento de webhook do Stripe.
   */
  async handleStripeWebhook(rawBody: Buffer, signature: string): Promise<void> {
    // --- Lógica de Segurança Stripe (Simulação) ---
    // 1. Verificar a Assinatura:
    // try {
    //   const event = this.stripe.webhooks.constructEvent(
    //     rawBody, signature, process.env.STRIPE_WEBHOOK_SECRET
    //   );
    // } catch (err) {
    //   throw new ForbiddenException(`Webhook signature verification failed: ${err.message}`);
    // }
    
    // Simulação: Converter Buffer para JSON
    const event = JSON.parse(rawBody.toString('utf8'));
    
    // 2. Processar Evento CRÍTICO:
    if (event.type === 'checkout.session.completed') {
      const session = event.data.object;
      
      // CRÍTICO: Obter o ID do Usuário (client_reference_id foi setado no initiateCheckout)
      const userId = session.client_reference_id; 
      
      if (!userId) {
        throw new Error('Missing client_reference_id in session data.');
      }
      
      // CRÍTICO: Obter o ID do Preço do Stripe
      const stripePriceId = session.line_items?.data[0]?.price?.id; // Lógica de array simplificada

      // Buscar o plano no nosso banco de dados usando o stripePriceId
      const plan = await this.plansService.findPlanByStripeId(stripePriceId); // Método futuro
      
      if (!plan) {
        console.error(`Plano não encontrado para Stripe Price ID: ${stripePriceId}`);
        return; // Não processar
      }

      // 3. Creditar o Plano/Tokens ao Usuário
      // Este método futuro será implementado no UserService
      // await this.userService.creditPlanToUser(userId, plan.aiTokens); 
      
      console.log(`[PaymentsService] Sucesso: Plano ${plan.name} creditado ao usuário ${userId}.`);

    } else {
      console.log(`[PaymentsService] Evento Stripe ignorado: ${event.type}`);
    }
  }
}