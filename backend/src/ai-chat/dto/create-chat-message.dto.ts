// backend/src/ai-chat/dto/create-chat-message.dto.ts

import { IsNotEmpty, IsString, MaxLength, IsOptional, IsInt } from 'class-validator';

/**
 * Data Transfer Object (DTO) para o envio de uma nova mensagem ao Chat de IA.
 * * Garante a integridade e tipagem do texto da mensagem e o contexto da conversa.
 */
export class CreateChatMessageDto {
  @IsNotEmpty({ message: 'A mensagem não pode ser vazia.' })
  @IsString({ message: 'A mensagem deve ser uma string de texto.' })
  @MaxLength(2000, { message: 'A mensagem excede o limite de 2000 caracteres.' })
  message: string; // Conteúdo da mensagem enviada pelo usuário

  @IsOptional()
  @IsInt({ message: 'O ID da conversa deve ser um número inteiro.' })
  /**
   * Identificador da conversa para manter o contexto.
   * Se for nulo/omitido, o serviço deve iniciar uma nova conversa.
   */
  conversationId?: number;
}