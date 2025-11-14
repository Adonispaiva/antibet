// backend/src/payments/interfaces/webhook-body.interface.ts

/**
 * Interface que representa o corpo da requisição (payload) de um Webhook de Pagamento.
 * * NOTA: O conteúdo exato deste payload varia dependendo do gateway de pagamento (ex: Stripe, Mercado Pago).
 * * O DTO/Interface é usado aqui para tipar o contrato de entrada do Controller, mas a validação de segurança 
 * (verificação da assinatura do webhook) é realizada no Service, antes de processar o evento.
 */
export interface WebhookBody {
  /**
   * ID único do evento de webhook.
   */
  id: string; 

  /**
   * Tipo do evento de webhook (ex: 'checkout.session.completed', 'invoice.paid').
   */
  type: string;

  /**
   * Objeto de dados do evento.
   */
  data: {
    object: any; // O objeto de evento real (PaymentIntent, Subscription, etc.)
  };

  /**
   * Timestamp da criação do evento.
   */
  created: number; 

  // Outros campos dependentes do provedor (ex: livemode, request, api_version)
  [key: string]: any; 
}