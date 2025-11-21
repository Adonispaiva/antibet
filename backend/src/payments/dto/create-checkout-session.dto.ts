import { IsNotEmpty, IsUUID } from 'class-validator';

/**
 * Data Transfer Object (DTO) para validar o payload
 * da requisicao de criacao de uma sessao de checkout.
 */
export class CreateCheckoutSessionDto {
  @IsUUID('4', { message: 'O ID do plano (planId) deve ser um UUID valido.' })
  @IsNotEmpty({ message: 'O ID do plano (planId) e obrigatorio.' })
  planId: string;
}