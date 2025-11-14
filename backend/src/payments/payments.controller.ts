// backend/src/payments/payments.controller.ts

import { Controller, Post, Body, UseGuards, Req, Get, HttpCode, HttpStatus } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { Request } from 'express';

import { PaymentsService } from './payments.service';
import { CreateCheckoutSessionDto } from './dto/create-checkout-session.dto';
import { WebhookBody } from './interfaces/webhook-body.interface'; // A interface de webhook

// Assumindo a existência de um Decorator @Public para desativar a proteção global
// Se não houver, precisa ser implementado ou usar @SkipAuth do pacote nestjs-public.
const Public = () => (_target: any, _key?: any, _descriptor?: any) => {};

/**
 * Interface customizada para a requisição com o objeto User injetado.
 */
interface RequestWithUser extends Request {
  user: { id: number; email: string }; // Propriedades essenciais injetadas pelo JwtStrategy
}

@Controller('payments')
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  /**
   * Endpoint de Usuário: Inicia o fluxo de pagamento para um plano.
   * Requer autenticação (JWT).
   * @param req A requisição com o usuário injetado.
   * @param createCheckoutSessionDto O DTO com o ID do plano e URLs de retorno.
   * @returns URL de redirecionamento para o gateway de pagamento.
   */
  @Post('checkout')
  @UseGuards(AuthGuard('jwt'))
  async createCheckoutSession(
    @Req() req: RequestWithUser,
    @Body() createCheckoutSessionDto: CreateCheckoutSessionDto,
  ): Promise<{ redirectUrl: string }> {
    const userId = req.user.id;
    // Delega a criação da sessão de checkout (API Gateway) para o serviço.
    const redirectUrl = await this.paymentsService.createCheckoutSession(
      userId,
      createCheckoutSessionDto,
    );
    return { redirectUrl };
  }

  /**
   * Endpoint do Gateway: Recebe eventos de Webhook do provedor de pagamento.
   * Não requer autenticação (Public).
   * NOTA DE SEGURANÇA: Este endpoint deve ser configurado no `main.ts` para
   * usar um Body Parser de requisição RAW (crua) para que a validação de assinatura
   * do webhook (na camada de Serviço) funcione corretamente.
   * @param req A requisição bruta, contendo o corpo e o header de assinatura.
   */
  @Post('webhook')
  @Public() // Marca como rota pública
  @HttpCode(HttpStatus.OK)
  async handleWebhook(@Req() req: Request): Promise<void> {
    // A validação da assinatura do webhook (req.headers['stripe-signature'] ou similar)
    // deve ser feita no Service usando req.rawBody (se configurado) ou o Body como WebhookBody.
    const signature = req.headers['stripe-signature'] as string; // Exemplo para Stripe
    const rawBody: WebhookBody = req.body; 
    
    // Delega o processamento do evento de webhook para o serviço.
    await this.paymentsService.handleWebhookEvent(rawBody, signature);
    // Retorna 200 OK imediatamente.
  }

  /**
   * Endpoint de Usuário: Retorna o status de assinatura do usuário logado.
   * Requer autenticação (JWT).
   * @param req A requisição com o usuário injetado.
   * @returns O status da assinatura (SubscriptionModel simplificado/DTO).
   */
  @Get('status')
  @UseGuards(AuthGuard('jwt'))
  async getSubscriptionStatus(@Req() req: RequestWithUser) {
    const userId = req.user.id;
    // Delega a busca pelo status da assinatura (a ser lido do BD) para o serviço.
    return this.paymentsService.getSubscriptionStatus(userId);
  }
}