import {
  IsBoolean,
  IsDateString,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';

/**
 * DTO para validar a criação de uma nova Meta.
 */
export class CreateGoalDto {
  @IsString()
  @IsNotEmpty({ message: 'O título não pode estar vazio.' })
  @MaxLength(255)
  title: string;

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  description?: string;

  @IsOptional()
  @IsDateString({}, { message: 'Data de conclusão deve ser uma data válida.' })
  dueDate?: Date;
}