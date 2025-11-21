import {
  IsInt,
  IsOptional,
  IsString,
  IsArray,
  IsDateString,
} from 'class-validator';
import { PartialType } from '@nestjs/mapped-types';
import { CreateJournalEntryDto } from './create-journal-entry.dto';

/**
 * Data Transfer Object (DTO) para atualizar uma entrada existente no diário.
 * Usa PartialType para tornar todos os campos de CreateJournalEntryDto opcionais.
 */
export class UpdateJournalEntryDto extends PartialType(CreateJournalEntryDto) {
  // O PartialType herda todos os campos e validacoes de CreateJournalEntryDto,
  // mas os torna opcionais.
  
  @IsString({ message: 'O conteúdo do diário deve ser um texto.' })
  @IsOptional()
  content?: string;

  @IsInt({ message: 'O valor de P&L deve ser um numero inteiro em centavos.' })
  @IsOptional()
  pnlValue?: number;

  @IsArray({ message: 'As tags devem ser fornecidas como um array de strings.' })
  @IsString({ each: true, message: 'Cada tag deve ser uma string.' })
  @IsOptional()
  tags?: string[];

  @IsDateString({}, { message: 'A data da operacao (tradeDate) deve ser uma string de data valida.' })
  @IsOptional()
  tradeDate?: string;
}