// backend/src/goals/dto/create-goal.dto.ts

import { IsNotEmpty, IsString, IsNumber, Min, IsDateString, MaxLength, IsOptional } from 'class-validator';

/**
 * Data Transfer Object (DTO) para a criação de uma nova meta do usuário.
 * * Garante a integridade e tipagem dos dados de entrada para o módulo Goals.
 */
export class CreateGoalDto {
  @IsNotEmpty({ message: 'O título da meta é obrigatório.' })
  @IsString({ message: 'O título da meta deve ser uma string.' })
  @MaxLength(100)
  title: string;

  @IsOptional()
  @IsString({ message: 'A descrição deve ser uma string.' })
  @MaxLength(500)
  description?: string;

  @IsNotEmpty({ message: 'O valor alvo (targetAmount) é obrigatório.' })
  @IsNumber({}, { message: 'O valor alvo deve ser um número.' })
  @Min(0, { message: 'O valor alvo não pode ser negativo.' })
  targetAmount: number; // Ex: R$ 5000.00

  @IsNotEmpty({ message: 'A data alvo (targetDate) é obrigatória.' })
  @IsDateString({}, { message: 'A data alvo deve ser uma string de data válida (ISO 8601).' })
  targetDate: string; // Ex: "2026-12-31"

  @IsOptional()
  @IsNumber({}, { message: 'O progresso atual deve ser um número.' })
  @Min(0, { message: 'O progresso atual não pode ser negativo.' })
  currentAmount?: number; // Progresso atual (padrão é 0.0)
}