import {
  IsNotEmpty,
  IsString,
  MinLength,
} from 'class-validator';

/**
 * Data Transfer Object (DTO) para enviar uma nova mensagem
 * do usuario para o chat com a IA.
 */
export class CreateChatMessageDto {
  @IsString({ message: 'O conteudo da mensagem deve ser um texto.' })
  @IsNotEmpty({ message: 'O conteudo da mensagem (content) e obrigatorio.' })
  @MinLength(1, { message: 'A mensagem nao pode ser vazia.' })
  content: string;
}