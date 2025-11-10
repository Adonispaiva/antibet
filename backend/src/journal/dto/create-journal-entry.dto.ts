import { IsEnum, IsNotEmpty, IsString, MaxLength } from 'class-validator';
import { JournalMood } from '../entities/journal-entry.entity';

/**
 * DTO para validar a criação de uma nova entrada de diário.
 */
export class CreateJournalEntryDto {
  @IsString()
  @IsNotEmpty({ message: 'O conteúdo não pode estar vazio.' })
  @MaxLength(5000, { message: 'A entrada do diário é muito longa.' })
  content: string;

  @IsEnum(JournalMood, { message: 'Humor inválido.' })
  mood: JournalMood;
}