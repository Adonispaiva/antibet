// backend/src/ai-chat/dto/ai-chat-response.dto.ts

import { IsNotEmpty, IsString, IsBoolean, IsOptional, IsInt } from 'class-validator';

/**
 * Data Transfer Object (DTO) para a resposta do servidor ao Mobile após a interação com a IA.
 * * Tipa o conteúdo da resposta e inclui informações cruciais sobre o status de limite de uso.
 */
export class AiChatResponseDto {
  @IsNotEmpty()
  @IsString()
  /**
   * O texto da mensagem gerada pela Inteligência Artificial.
   */
  message: string;

  @IsNotEmpty()
  @IsInt()
  /**
   * O ID da conversa persistente.
   */
  conversationId: number;

  @IsNotEmpty()
  @IsBoolean()
  /**
   * Indica se o usuário excedeu o limite de uso de IA do seu plano.
   * O Front-end deve usar este campo para bloquear novas requisições ou exibir um aviso.
   */
  limitExceeded: boolean;

  @IsOptional()
  @IsInt()
  /**
   * Número de interações restantes no plano do usuário.
   */
  remainingInteractions?: number;
}