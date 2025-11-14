// backend/src/goals/dto/update-goal.dto.ts

import { IsString, IsNumber, Min, IsDateString, MaxLength, IsOptional, IsBoolean } from 'class-validator';

/**
 * Data Transfer Object (DTO) para a atualização parcial de uma meta (PATCH).
 * * Todos os campos são opcionais, permitindo ao usuário atualizar apenas uma parte 
 * da meta (ex: progresso atual ou status de conclusão).
 */
export class UpdateGoalDto {
  @IsOptional()
  @IsString({ message: 'O título da meta deve ser uma string.' })
  @MaxLength(100)
  title?: string;

  @IsOptional()
  @IsString({ message: 'A descrição deve ser uma string.' })
  @MaxLength(500)
  description?: string;

  @IsOptional()
  @IsNumber({}, { message: 'O valor alvo deve ser um número.' })
  @Min(0, { message: 'O valor alvo não pode ser negativo.' })
  targetAmount?: number; // Ex: R$ 5000.00

  @IsOptional()
  @IsDateString({}, { message: 'A data alvo deve ser uma string de data válida (ISO 8601).' })
  targetDate?: string; // Ex: "2026-12-31"

  @IsOptional()
  @IsNumber({}, { message: 'O progresso atual deve ser um número.' })
  @Min(0, { message: 'O progresso atual não pode ser negativo.' })
  currentAmount?: number; // Progresso atual

  @IsOptional()
  @IsBoolean({ message: 'O status de conclusão deve ser um booleano.' })
  isCompleted?: boolean; // Permite marcar a meta como concluída
}