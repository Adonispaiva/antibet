// backend/src/strategy/dto/create-strategy.dto.ts

import { IsNotEmpty, IsString, IsOptional, MaxLength } from 'class-validator';

/**
 * Data Transfer Object (DTO) para a criação de uma nova estratégia de análise.
 * * Garante a integridade e tipagem dos dados de entrada para o módulo Strategy.
 */
export class CreateStrategyDto {
  @IsNotEmpty({ message: 'O nome da estratégia é obrigatório.' })
  @IsString({ message: 'O nome da estratégia deve ser uma string.' })
  @MaxLength(100)
  name: string;

  @IsOptional()
  @IsString({ message: 'A descrição da estratégia deve ser uma string.' })
  @MaxLength(1000)
  description?: string; // Descrição detalhada da regra/abordagem da estratégia
}