import {
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';
import { StrategyFocus } from '../entities/strategy.entity';

/**
 * Data Transfer Object (DTO) para criar uma nova estratégia de trading.
 */
export class CreateStrategyDto {
  @IsString({ message: 'O nome da estrategia deve ser um texto.' })
  @IsNotEmpty({ message: 'O nome e obrigatorio.' })
  name: string;

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