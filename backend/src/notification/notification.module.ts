import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Notification } from './entities/notification.entity';
import { NotificationService } from './notification.service';
import { NotificationController } from './notification.controller';
import { UserModule } from '../user/user.module'; // Necessario se o NotificationService for buscar dados do usuario

@Module({
  imports: [
    // Registra a entidade Notification no TypeORM
    TypeOrmModule.forFeature([Notification]),
    // Opcionalmente, importar UserModule se o NotificationService interagir com o UserService
    UserModule,
  ],
  controllers: [NotificationController],
  providers: [NotificationService],
  // O NotificationService deve ser exportado caso o GoalsModule, PaymentsModule ou AiChatModule
  // precise disparar novas notificações de forma interna.
  exports: [NotificationService], 
})
export class NotificationModule {}