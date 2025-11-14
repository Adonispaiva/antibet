// backend/src/ai-chat/ai-chat.controller.ts

import { 
  Controller, 
  Get, 
  Post, 
  Body, 
  UseGuards, 
  Req, 
  Param, 
  ParseIntPipe,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { Request } from 'express';

import { AiChatService } from './ai-chat.service';
import { CreateChatMessageDto } from './dto/create-chat-message.dto';
import { AiChatResponseDto } from './dto/ai-chat-response.dto'; // DTO de Resposta
import { User } from '../user/entities/user.entity'; // A Entidade de Usuário

/**
 * Interface customizada para a requisição com o objeto User injetado pelo JwtStrategy.
 */
interface RequestWithUser extends Request {
  user: User;
}

@Controller('ai-chat')
@UseGuards(AuthGuard('jwt')) // Protege todas as rotas deste controller
export class AiChatController {
  constructor(private readonly aiChatService: AiChatService) {}

  /**
   * Endpoint Principal: Envia uma mensagem ao chat de IA e recebe a resposta.
   */
  @Post('message')
  async sendMessage(
    @Body() createMessageDto: CreateChatMessageDto,
    @Req() req: RequestWithUser,
  ): Promise<AiChatResponseDto> {
    const userId = req.user.id;
    return this.aiChatService.sendMessage(createMessageDto, userId);
  }

  /**
   * Lista todas as conversas do usuário (histórico).
   * NOTE: O método findConversations deve ser implementado no AiChatService.
   */
  @Get('conversations')
  listConversations(@Req() req: RequestWithUser) {
    const userId = req.user.id;
    // Omitido do Service para manter o foco no sendMessage, mas deve ser implementado.
    // return this.aiChatService.findConversations(userId);
    return []; // Retorno placeholder para método não implementado
  }

  /**
   * Lista as mensagens de uma conversa específica.
   * NOTE: O método findMessages deve ser implementado no AiChatService.
   */
  @Get('messages/:conversationId')
  listMessages(
    @Param('conversationId', ParseIntPipe) conversationId: number,
    @Req() req: RequestWithUser,
  ) {
    const userId = req.user.id;
    // Omitido do Service para manter o foco no sendMessage, mas deve ser implementado.
    // return this.aiChatService.findMessages(conversationId, userId);
    return []; // Retorno placeholder para método não implementado
  }
}