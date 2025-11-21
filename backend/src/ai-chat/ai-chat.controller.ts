import {
  Controller,
  Get,
  Post,
  Body,
  UseGuards,
  Request,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

import { AiChatService } from './ai-chat.service';
import { CreateChatMessageDto } from './dto/create-chat-message.dto';
import { ChatMessage } from './entities/chat-message.entity';

// Interface para garantir o objeto user injetado pelo JwtStrategy
interface RequestWithUser extends Request {
  user: {
    userId: string;
    email: string;
    role: string;
  };
}

@UseGuards(AuthGuard('jwt')) // Protege todas as rotas deste controlador
@Controller('ai-chat') // O nome do endpoint e padrao RESTful
export class AiChatController {
  constructor(private readonly aiChatService: AiChatService) {}

  /**
   * Envia uma nova mensagem do usuário para a IA e recebe a resposta.
   * (POST /ai-chat)
   */
  @Post()
  async sendMessage(
    @Request() req: RequestWithUser,
    @Body() createChatMessageDto: CreateChatMessageDto,
  ): Promise<ChatMessage> {
    const user = { id: req.user.userId } as any; // Objeto user simplificado
    return this.aiChatService.processUserMessage(user, createChatMessageDto);
  }

  /**
   * Recupera o histórico de mensagens do usuário logado.
   * (GET /ai-chat)
   */
  @Get()
  async getHistory(@Request() req: RequestWithUser): Promise<ChatMessage[]> {
    return this.aiChatService.getChatHistory(req.user.userId);
  }
}