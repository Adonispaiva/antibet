import {
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsArray,
  IsDateString,
} from 'class-validator';

/**
 * Data Transfer Object (DTO) para criar uma nova entrada no diário.
 */
export class CreateJournalEntryDto {
  @IsString({ message: 'O conteúdo do diário deve ser um texto.' })
  @IsNotEmpty({ message: 'O conteúdo do diário (content) e obrigatorio.' })
  content: string;

  @IsInt({ message: 'O valor de P&L deve ser um numero inteiro em centavos.' })
  @IsOptional()
  pnlValue?: number;

  @IsArray({ message: 'As tags devem ser fornecidas como um array de strings.' })
  @IsString({ each: true, message: 'Cada tag deve ser uma string.' })
  @IsOptional()
  tags?: string[];

  @IsDateString({}, { message: 'A data da operacao (tradeDate) deve ser uma string de data valida.' })
  @IsOptional()
  tradeDate?: string; // Usamos string aqui e convertemos para Date no service/controller se necessario
}