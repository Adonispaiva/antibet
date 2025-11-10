import { IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class MessageDto {
  @IsString({ message: 'A mensagem deve ser uma string.' })
  @IsNotEmpty({ message: 'A mensagem não pode ser vazia.' })
  @MaxLength(500, { message: 'A mensagem não pode exceder 500 caracteres.' })
  message: string;
}