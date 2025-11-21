import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { AiChatController } from './ai-chat.controller';
import { AiChatService } from './ai-chat.service';
import { ChatMessage } from './entities/chat-message.entity';
import { AppConfigurationModule } from '../../config/config.module'; // Necessario para o AppConfigService

@Module({
  imports: [
    // Registra a entidade ChatMessage no TypeORM
    TypeOrmModule.forFeature([ChatMessage]),
    // Necessario para injetar o AppConfigService no AiChatService (chaves da API de IA)
    AppConfigurationModule, 
  ],
  controllers: [AiChatController],
  providers: [AiChatService],
  // O AiChatService pode ser exportado caso outros módulos (ex: Journal)
  // queiram usar a IA para análise de texto.
  exports: [AiChatService], 
})
export class AiChatModule {}