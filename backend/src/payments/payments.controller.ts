import { Controller, Post, Body, UseGuards, Request, RawBodyRequest, Get, HttpCode, HttpStatus } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { PaymentsService } from './payments.service';
import { CreateCheckoutSessionDto } from './dto/create-checkout-session.dto';

/**
 * Interface customizada para a requisição com o objeto User injetado.
 */
interface RequestWithUser extends Request {
  user: {
    userId: string;
    email: string;
    role: string;
  };
}

@Controller('payments')
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  /**
   * Endpoint de Usuário: Inicia o fluxo de pagamento para um plano.
   * (Corrigido para /checkout, conforme sua sugestao)
   */
  @UseGuards(AuthGuard('jwt'))
  @Post('checkout')
  async createCheckoutSession(
    @Request() req: RequestWithUser,
    @Body() createCheckoutSessionDto: CreateCheckoutSessionDto,
  ): Promise<{ url: string }> {
    const userId = req.user.userId;
    const { planId } = createCheckoutSessionDto;
    
    return this.paymentsService.createCheckoutSession(userId, planId);
  }

  /**
   * Endpoint do Gateway: Recebe eventos de Webhook (ex: Stripe).
   * (Corrigido para usar RawBodyRequest para validacao de assinatura)
   */
  @Post('webhook/stripe')
  @HttpCode(HttpStatus.OK)
  async handleStripeWebhook(@Request() req: RawBodyRequest<Request>) {
    const signature = req.headers['stripe-signature'] as string;
    
    // O rawBody (Buffer) e essencial para a validacao da assinatura.
    if (!req.rawBody) {
      throw new Error('Raw body buffer nao encontrado. Configure o RawBodyMiddleware.');
    }

    return this.paymentsService.handleStripeWebhook(signature, req.rawBody);
  }

  /**
   * Endpoint de Usuário: Retorna o status de assinatura do usuário logado.
   * (Adicionado conforme sua sugestao)
   */
  @UseGuards(AuthGuard('jwt'))
  @Get('status')
  async getSubscriptionStatus(@Request() req: RequestWithUser) {
    const userId = req.user.userId;
    // O SubscriptionService (injetado no PaymentsService) contera a logica
    return this.subscriptionService.findByUserId(userId); 
    // Nota: Precisamos injetar o SubscriptionService no PaymentsService
  }
}