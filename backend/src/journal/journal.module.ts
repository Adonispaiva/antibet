// backend/src/journal/journal.module.ts

import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { JournalService } from './journal.service';
import { JournalController } from './journal.controller';
import { JournalEntry } from './entities/journal-entry.entity'; // A Entidade de Diário
import { AuthModule } from '../auth/auth.module'; // Dependência para segurança
import { UserModule } from '../user/user.module'; // Dependência para User
import { StrategyModule } from '../strategy/strategy.module'; // Dependência para relação com Estratégia

@Module({
  imports: [
    // 1. Importa a entidade JournalEntry e TypeOrm
    TypeOrmModule.forFeature([JournalEntry]),

    // 2. Importa o AuthModule para proteção de rotas
    forwardRef(() => AuthModule), 

    // 3. Importa o UserModule e StrategyModule (se necessário no Service)
    forwardRef(() => UserModule), 
    forwardRef(() => StrategyModule), 
  ],
  controllers: [JournalController],
  providers: [
    JournalService, // Serviço de lógica de negócio do diário
  ],
  exports: [
    JournalService, // Exporta o serviço para outros módulos (ex: MetricsService)
    TypeOrmModule, // Exporta o TypeOrmModule do diário
  ],
})
export class JournalModule {}