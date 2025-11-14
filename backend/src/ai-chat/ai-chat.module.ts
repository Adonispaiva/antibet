// backend/src/ai-chat/ai-chat.module.ts

import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { AiChatService } from './ai-chat.service';
import { AiChatController } from './ai-chat.controller';
import { AiChatConversation } from './entities/ai-chat-conversation.entity'; // Entidade de Conversa
import { AiChatMessage } from './entities/ai-chat-message.entity'; // Entidade de Mensagem

import { AuthModule } from '../auth/auth.module'; // Dependência para segurança
import { UserModule } from '../user/user.module'; // Dependência para limites de uso
import { PaymentsModule } from '../payments/payments.module'; // Dependência para status Premium

@Module({
  imports: [
    // 1. Importa as entidades de chat e TypeOrm
    TypeOrmModule.forFeature([AiChatConversation, AiChatMessage]),

    // 2. Importa o AuthModule para proteção de rotas
    forwardRef(() => AuthModule), 

    // 3. Importa o UserModule (para buscar dados do usuário, se necessário)
    forwardRef(() => UserModule), 

    // 4. Importa o PaymentsModule (para verificar limites e status Premium)
    forwardRef(() => PaymentsModule), 
  ],
  controllers: [AiChatController],
  providers: [
    AiChatService, // Serviço de lógica de negócio e integração com LLM
  ],
  exports: [
    AiChatService, // Exporta o serviço para outros módulos
    TypeOrmModule, // Exporta o TypeOrmModule de chat
  ],
})
export class AiChatModule {}