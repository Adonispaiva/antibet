import { Controller, Post, Headers, Req, Res, RawBody } from '@nestjs/common';
import { PaymentsService } from './payments.service';
import { Response } from 'express';

@Controller('payments')
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  /**
   * Rota dedicada para o Stripe Webhook.
   * Não requer autenticação, mas verifica a assinatura do Stripe.
   */
  @Post('webhook')
  async handleWebhook(
    @Headers('stripe-signature') signature: string,
    @Req() req: any,
    @Res() res: Response,
  ): Promise<void> {
    
    // O @RawBody decorator deve ser configurado para o NestJS para obter req.rawBody
    const rawBody = req.rawBody; 

    if (!signature || !rawBody) {
        // Responder 400 se faltar o header ou o corpo.
        res.status(400).send('Webhook Error: Missing signature or body');
        return;
    }

    try {
      // O Service lida com a verificação de segurança e processamento do evento.
      await this.paymentsService.handleStripeWebhook(rawBody, signature);
      
      // Responder 200 OK para o Stripe
      res.status(200).send({ received: true });

    } catch (error) {
      // Responder 400 para o Stripe (ex: falha na verificação de assinatura)
      console.error('Stripe Webhook Processing Error:', error);
      res.status(400).send(`Webhook Error: ${error.message}`);
    }
  }
}