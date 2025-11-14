// backend/src/payments/dto/create-checkout-session.dto.ts

import { IsNotEmpty, IsInt, IsOptional, IsString, IsUrl } from 'class-validator';

/**
 * Data Transfer Object (DTO) para iniciar uma nova sessão de checkout de pagamento.
 * * Usado para enviar as informações necessárias para o Backend interagir com o gateway de pagamento (ex: Stripe).
 */
export class CreateCheckoutSessionDto {
  @IsNotEmpty({ message: 'O ID do plano é obrigatório.' })
  @IsInt({ message: 'O ID do plano deve ser um número inteiro.' })
  planId: number; // ID do plano de assinatura selecionado

  @IsOptional()
  @IsString({ message: 'O código do cupom deve ser uma string.' })
  @IsNotEmpty({ message: 'O código do cupom não pode ser vazio.' })
  couponCode?: string; // Código de cupom opcional

  @IsNotEmpty({ message: 'A URL de sucesso é obrigatória.' })
  @IsUrl({}, { message: 'A URL de sucesso deve ser um formato de URL válido.' })
  /**
   * URL para redirecionar o cliente após a conclusão bem-sucedida do pagamento.
   */
  successUrl: string;

  @IsNotEmpty({ message: 'A URL de cancelamento é obrigatória.' })
  @IsUrl({}, { message: 'A URL de cancelamento deve ser um formato de URL válido.' })
  /**
   * URL para redirecionar o cliente se o pagamento for cancelado ou falhar.
   */
  cancelUrl: string;
}