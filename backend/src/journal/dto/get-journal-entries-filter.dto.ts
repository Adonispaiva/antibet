// backend/src/journal/dto/get-journal-entries-filter.dto.ts

import { IsOptional, IsString, IsDateString, IsIn } from 'class-validator';

/**
 * Data Transfer Object (DTO) para filtrar a listagem de entradas do diário.
 * * Todos os campos são opcionais e usados para criar cláusulas WHERE na consulta ao banco de dados.
 */
export class GetJournalEntriesFilterDto {
  @IsOptional()
  @IsString({ message: 'O filtro de estratégia deve ser uma string.' })
  strategyName?: string; // Filtra pelo nome da estratégia utilizada

  @IsOptional()
  @IsDateString({}, { message: 'A data de início deve ser uma string de data válida (ISO 8601).' })
  startDate?: string; // Filtra entradas a partir desta data (ex: entryDate >= startDate)

  @IsOptional()
  @IsDateString({}, { message: 'A data de fim deve ser uma string de data válida (ISO 8601).' })
  endDate?: string; // Filtra entradas até esta data (ex: entryDate <= endDate)

  @IsOptional()
  @IsIn(['Win', 'Loss', 'Even'], { message: "O resultado deve ser 'Win', 'Loss' ou 'Even'." })
  /**
   * Filtra pelo resultado final da aposta.
   * A lógica de conversão (ex: finalResult > 0 é 'Win') deve estar na camada de serviço.
   */
  resultType?: 'Win' | 'Loss' | 'Even'; 
}