// backend/src/app.module.ts

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';

// Importação do Módulo de Configuração Customizado
import { AppConfigurationModule } from './config/config.module';
import { AppConfigService } from './config/app-config.service';

// Importação de todos os Módulos de Feature
import { AuthModule } from './auth/auth.module';
import { UserModule } from './user/user.module';
import { PlansModule } from './plans/plans.module';
import { PaymentsModule } from './payments/payments.module';
import { JournalModule } from './journal/journal.module';
import { StrategyModule } from './strategy/strategy.module';
import { GoalsModule } from './goals/goals.module';
import { NotificationModule } from './notification/notification.module';
import { AiChatModule } from './ai-chat/ai-chat.module';

@Module({
  imports: [
    // 1. Importa o Módulo de Configuração Central
    AppConfigurationModule,

    // 2. Conexão com o Banco de Dados (TypeORM)
    TypeOrmModule.forRootAsync({
      // O AppConfigService já é exportado pelo AppConfigurationModule
      imports: [AppConfigurationModule], 
      // Injeta o AppConfigService
      inject: [AppConfigService], 

      useFactory: (appConfigService: AppConfigService) => ({
        type: 'postgres',
        host: appConfigService.DB_HOST,
        port: appConfigService.DB_PORT,
        username: appConfigService.DB_USERNAME,
        password: appConfigService.DB_PASSWORD,
        database: appConfigService.DB_DATABASE,
        entities: [__dirname + '/**/*.entity{.ts,.js}'],
        synchronize: true,
      }),
    }),

    // 3. Módulos de Feature
    AuthModule,
    UserModule,
    PlansModule,
    PaymentsModule,
    JournalModule,
    StrategyModule,
    GoalsModule,
    NotificationModule,
    AiChatModule,
  ],
  controllers: [AppController],
  // Apenas o AppService é necessário, pois o AppConfigService agora
  // é provido e exportado pelo AppConfigurationModule.
  providers: [AppService], 
})
export class AppModule {}