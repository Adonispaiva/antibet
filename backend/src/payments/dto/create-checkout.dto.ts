import { IsNotEmpty, IsUUID } from 'class-validator';

/**
 * DTO para validar a criação de uma sessão de checkout.
 */
export class CreateCheckoutDto {
  @IsUUID(4, { message: 'ID do plano inválido.' })
  @IsNotEmpty()
  planId: string;
}