// backend/src/notification/notification.module.ts

import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { NotificationService } from './notification.service';
import { NotificationController } from './notification.controller';
import { Notification } from './entities/notification.entity'; // A Entidade de Notificação
import { AuthModule } from '../auth/auth.module'; // Dependência para segurança
import { UserModule } from '../user/user.module'; // Dependência para User

@Module({
  imports: [
    // 1. Importa a entidade Notification e TypeOrm
    TypeOrmModule.forFeature([Notification]),

    // 2. Importa o AuthModule para proteção de rotas
    forwardRef(() => AuthModule), 

    // 3. Importa o UserModule
    forwardRef(() => UserModule), 
  ],
  controllers: [NotificationController],
  providers: [
    NotificationService, // Serviço de lógica de negócio de notificação
  ],
  exports: [
    NotificationService, // Exporta o serviço para outros módulos (ex: para criar alertas)
    TypeOrmModule, // Exporta o TypeOrmModule de notificação
  ],
})
export class NotificationModule {}