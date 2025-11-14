// backend/src/journal/dto/create-journal-entry.dto.ts

import { IsNotEmpty, IsNumber, IsString, IsOptional, Min, Max, IsDateString } from 'class-validator';

/**
 * Data Transfer Object (DTO) para a criação de uma nova entrada no diário.
 * * Garante a integridade dos dados financeiros e analíticos enviados pelo Mobile.
 */
export class CreateJournalEntryDto {
  @IsNotEmpty({ message: 'O valor da aposta (stake) é obrigatório.' })
  @IsNumber({}, { message: 'O valor da aposta deve ser um número.' })
  @Min(0, { message: 'O valor da aposta não pode ser negativo.' })
  stake: number; // Valor apostado/investido

  @IsNotEmpty({ message: 'O resultado final é obrigatório.' })
  @IsNumber({}, { message: 'O resultado final deve ser um número.' })
  // O resultado final pode ser negativo (prejuízo)
  finalResult: number; 

  @IsNotEmpty({ message: 'A data da entrada é obrigatória.' })
  @IsDateString({}, { message: 'A data deve ser uma string de data válida (ISO 8601).' })
  entryDate: string; // Data e hora da entrada (ISO 8601)

  @IsNotEmpty({ message: 'O nome da estratégia é obrigatório.' })
  @IsString({ message: 'O nome da estratégia deve ser uma string.' })
  strategyName: string;

  @IsNotEmpty({ message: 'A pré-análise é obrigatória.' })
  @IsString({ message: 'A pré-análise deve ser uma string.' })
  preAnalysis: string;

  @IsOptional()
  @IsString({ message: 'A pós-análise deve ser uma string.' })
  postAnalysis?: string; // Análise feita após o resultado (Opcional)

  @IsOptional()
  @IsString({ message: 'O tipo de esporte/mercado deve ser uma string.' })
  market?: string; // Ex: Futebol, Over/Under
}