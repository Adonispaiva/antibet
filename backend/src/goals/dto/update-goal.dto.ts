import {
  IsEnum,
  IsNumber,
  IsOptional,
  IsString,
  Min,
  IsDateString,
  IsBoolean,
} from 'class-validator';
import { PartialType } from '@nestjs/mapped-types';
import { CreateGoalDto } from './create-goal.dto';
import { GoalType } from '../entities/goal.entity';

/**
 * Data Transfer Object (DTO) para atualizar uma meta existente.
 * Usa PartialType para tornar todos os campos de CreateGoalDto opcionais.
 */
export class UpdateGoalDto extends PartialType(CreateGoalDto) {
  @IsString({ message: 'O titulo da meta deve ser um texto.' })
  @IsOptional()
  title?: string;

  @IsString({ message: 'A descricao deve ser um texto.' })
  @IsOptional()
  description?: string;

  @IsEnum(GoalType, { message: 'Tipo de meta invalido.' })
  @IsOptional()
  type?: GoalType;

  @IsNumber({}, { message: 'O valor alvo deve ser um numero.' })
  @Min(0, { message: 'O valor alvo nao pode ser negativo.' })
  @IsOptional()
  targetValue?: number;
  
  @IsNumber({}, { message: 'O valor atual deve ser um numero.' })
  @Min(0, { message: 'O valor atual nao pode ser negativo.' })
  @IsOptional()
  currentValue?: number; // Permite atualizar o progresso da meta

  @IsDateString({}, { message: 'A data alvo (targetDate) deve ser uma string de data valida.' })
  @IsOptional()
  targetDate?: string;

  @IsBoolean({ message: 'isCompleted deve ser um booleano.' })
  @IsOptional()
  isCompleted?: boolean;
}