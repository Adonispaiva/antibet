import { IsNotEmpty, IsString, IsUUID } from 'class-validator';

export class InitiateCheckoutDto {
  @IsString({ message: 'O ID do plano deve ser uma string.' })
  @IsNotEmpty({ message: 'O ID do plano (planId) é obrigatório.' })
  // No futuro, IsUUID ou Regex específico para o formato do ID do plano
  planId: string; 
}