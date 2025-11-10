import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AiLogService } from './ai-log.service';
import { AiInteractionLog } from './ai-log.entity';

@Module({
  imports: [
    // Registrando a Entidade de Log para uso de Repository neste módulo
    TypeOrmModule.forFeature([AiInteractionLog]), 
  ],
  providers: [
    AiLogService, // Service que fará a contagem e o registro
  ],
  controllers: [
    // Não precisamos de um Controller para Logs de Interação
  ],
  exports: [
    AiLogService, // Exportado para que o AiChatService possa usá-lo
  ]
})
export class AiLogModule {}