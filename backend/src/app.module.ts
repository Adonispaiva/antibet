// backend/src/app.module.ts

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';

// Módulos de Configuração
import { AppConfigurationModule } from './config/config.module';
import { AppConfigService } from './config/app-config.service';

// Módulos de Feature
import { AuthModule } from './auth/auth.module';
import { UserModule } from './user/user.module';
import { PlansModule } from './plans/plans.module';
import { PaymentsModule } from './payments/payments.module';
import { JournalModule } from './journal/journal.module';
import { StrategyModule } from './strategy/strategy.module';
import { GoalsModule } from './goals/goals.module';
import { NotificationModule } from './notification/notification.module';
import { AiChatModule } from './ai-chat/ai-chat.module';
import { SubscriptionModule } from './subscription/subscription.module'; // Adicionado

@Module({
  imports: [
    // 1. Configuração Global (Importa o AppConfigurationModule)
    AppConfigurationModule,

    // 2. Conexão com o Banco de Dados (TypeORM)
    TypeOrmModule.forRootAsync({
      imports: [AppConfigurationModule],
      inject: [AppConfigService],
      useFactory: (appConfigService: AppConfigService) => ({
        type: 'postgres',
        // Utiliza o novo serviço tipado
        host: appConfigService.DB_HOST,
        port: appConfigService.DB_PORT,
        username: appConfigService.DB_USERNAME,
        password: appConfigService.DB_PASSWORD,
        database: appConfigService.DB_DATABASE,
        // Procura entidades em todos os módulos
        entities: [__dirname + '/**/*.entity{.ts,.js}'], 
        synchronize: true, // Deve ser false em Producao
      }),
    }),

    // 3. Módulos de Feature
    UserModule, // Core
    AuthModule,
    SubscriptionModule,
    PlansModule,
    PaymentsModule,
    
    // Módulos de Domínio
    JournalModule,
    StrategyModule,
    GoalsModule,
    NotificationModule,
    AiChatModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}