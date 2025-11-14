// backend/src/strategy/strategy.module.ts

import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { StrategyService } from './strategy.service';
import { StrategyController } from './strategy.controller';
import { Strategy } from './entities/strategy.entity'; // A Entidade de Estratégia
import { AuthModule } from '../auth/auth.module'; // Dependência para segurança
import { UserModule } from '../user/user.module'; // Dependência para User

@Module({
  imports: [
    // 1. Importa a entidade Strategy e TypeOrm
    TypeOrmModule.forFeature([Strategy]),

    // 2. Importa o AuthModule para proteção de rotas
    forwardRef(() => AuthModule), 

    // 3. Importa o UserModule
    forwardRef(() => UserModule), 
  ],
  controllers: [StrategyController],
  providers: [
    StrategyService, // Serviço de lógica de negócio de estratégia
  ],
  exports: [
    StrategyService, // Exporta o serviço para outros módulos (ex: JournalModule)
    TypeOrmModule, // Exporta o TypeOrmModule de estratégia
  ],
})
export class StrategyModule {}