// backend/src/journal/dto/update-journal-entry.dto.ts

import { IsNumber, IsString, IsOptional, Min, Max, IsDateString } from 'class-validator';

/**
 * Data Transfer Object (DTO) para a atualização parcial de uma entrada no diário (PATCH).
 * * Todos os campos são opcionais, permitindo ao usuário atualizar apenas uma parte 
 * da entrada (ex: adicionar a pós-análise ou corrigir o resultado final).
 */
export class UpdateJournalEntryDto {
  @IsOptional()
  @IsNumber({}, { message: 'O valor da aposta deve ser um número.' })
  @Min(0, { message: 'O valor da aposta não pode ser negativo.' })
  stake?: number; // Valor apostado/investido

  @IsOptional()
  @IsNumber({}, { message: 'O resultado final deve ser um número.' })
  finalResult?: number; 

  @IsOptional()
  @IsDateString({}, { message: 'A data deve ser uma string de data válida (ISO 8601).' })
  entryDate?: string; // Data e hora da entrada (ISO 8601)

  @IsOptional()
  @IsString({ message: 'O nome da estratégia deve ser uma string.' })
  strategyName?: string;

  @IsOptional()
  @IsString({ message: 'A pré-análise deve ser uma string.' })
  preAnalysis?: string;

  @IsOptional()
  @IsString({ message: 'A pós-análise deve ser uma string.' })
  postAnalysis?: string; // Análise feita após o resultado (Opcional)

  @IsOptional()
  @IsString({ message: 'O tipo de esporte/mercado deve ser uma string.' })
  market?: string; // Ex: Futebol, Over/Under
}