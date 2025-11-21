import {
  IsEnum,
  IsNumber,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';
import { PartialType } from '@nestjs/mapped-types';
import { CreateStrategyDto } from './create-strategy.dto';
import { StrategyFocus } from '../entities/strategy.entity'; // Import corrigido para a pasta singular

/**
 * Data Transfer Object (DTO) para atualizar uma estratégia existente.
 * Usa PartialType para tornar todos os campos de CreateStrategyDto opcionais.
 */
export class UpdateStrategyDto extends PartialType(CreateStrategyDto) {
  @IsString({ message: 'O nome da estrategia deve ser um texto.' })
  @IsOptional()
  name?: string;

  @IsString({ message: 'A descricao deve ser um texto.' })
  @IsOptional()
  description?: string;

  @IsEnum(StrategyFocus, { message: 'Foco da estrategia invalido. Use SCALPING, SWING ou POSITION.' })
  @IsOptional()
  focus?: StrategyFocus;

  @IsNumber({}, { message: 'O risco por trade deve ser um numero.' })
  @Min(0, { message: 'O risco por trade nao pode ser negativo.' })
  @IsOptional()
  riskPerTrade?: number;

  @IsNumber({}, { message: 'O targetWinRate deve ser um numero.' })
  @Min(0, { message: 'O targetWinRate nao pode ser negativo.' })
  @IsOptional()
  targetWinRate?: number;
}