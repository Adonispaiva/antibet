import { Controller, Post, Body, Req, UseGuards } from '@nestjs/common';
import { AiChatService } from './ai-chat.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { MessageDto } from './dto/message.dto'; // DTO para a mensagem

@UseGuards(JwtAuthGuard)
@Controller('ai-chat')
export class AiChatController {
  constructor(private readonly aiChatService: AiChatService) {}

  /**
   * Rota protegida para enviar uma mensagem para a IA e receber a resposta.
   * Dispara a lógica de débito de uso no Backend.
   */
  @Post()
  async sendMessage(@Body() messageDto: MessageDto, @Req() req) {
    // O ID do usuário foi injetado na requisição pelo JwtAuthGuard
    const userId = req.user.id; 
    
    // CRÍTICO: Chamando o método correto 'sendMessage'
    return this.aiChatService.sendMessage(userId, messageDto.message);
  }
}