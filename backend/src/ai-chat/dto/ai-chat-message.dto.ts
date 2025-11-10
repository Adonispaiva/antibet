import { IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class AiChatMessageDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(2000, { message: 'A mensagem não pode exceder 2000 caracteres.' })
  message: string;
}