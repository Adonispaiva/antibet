import { Module } from '@nestjs/common';
import { AiChatService } from './ai-chat.service';
import { AiChatController } from './ai-chat.controller';
import { AiLogService } from './ai-log.service'; // NOVO: Importação do Log Service
// import { AiGatewayService } from './ai-gateway.service'; // Futuramente (GPT API)
// import { RateLimiterModule } from '../rate-limiter/rate-limiter.module'; // Futuramente

@Module({
  imports: [
    // RateLimiterModule,
  ],
  controllers: [AiChatController],
  providers: [
    AiChatService,
    AiLogService, // Service de Log e Débito
    // AiGatewayService,
  ],
  exports: [
    AiChatService,
    AiLogService, // Opcional, mas útil se outro módulo precisar de log
  ],
})
export class AiChatModule {}