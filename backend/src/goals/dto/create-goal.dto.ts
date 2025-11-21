import {
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Min,
  IsDateString,
} from 'class-validator';
import { GoalType } from '../entities/goal.entity';

/**
 * Data Transfer Object (DTO) para criar uma nova meta.
 */
export class CreateGoalDto {
  @IsString({ message: 'O titulo da meta deve ser um texto.' })
  @IsNotEmpty({ message: 'O titulo e obrigatorio.' })
  title: string;

  @IsString({ message: 'A descricao deve ser um texto.' })
  @IsOptional()
  description?: string;

  @IsEnum(GoalType, { message: 'Tipo de meta invalido. Use FINANCIAL, EMOTIONAL, TECHNICAL ou OTHER.' })
  @IsOptional()
  type?: GoalType;

  @IsNumber({}, { message: 'O valor alvo deve ser um numero.' })
  @Min(0, { message: 'O valor alvo nao pode ser negativo.' })
  @IsNotEmpty({ message: 'O valor alvo (targetValue) e obrigatorio.' })
  targetValue: number;

  @IsDateString({}, { message: 'A data alvo (targetDate) deve ser uma string de data valida.' })
  @IsOptional()
  targetDate?: string;
}