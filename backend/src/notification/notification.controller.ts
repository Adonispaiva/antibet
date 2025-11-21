import {
  Controller,
  Get,
  Patch,
  Param,
  UseGuards,
  Request,
  NotFoundException,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

import { NotificationService } from './notification.service';
import { Notification } from './entities/notification.entity';

// Interface para garantir o objeto user injetado pelo JwtStrategy
interface RequestWithUser extends Request {
  user: {
    userId: string;
    email: string;
    role: string;
  };
}

@UseGuards(AuthGuard('jwt')) // Protege todas as rotas deste controlador
@Controller('notifications') // O nome do endpoint e plural e o padrao RESTful
export class NotificationController {
  constructor(private readonly notificationService: NotificationService) {}

  /**
   * Lista todas as notificações do usuário logado (GET /notifications).
   */
  @Get()
  async findAll(@Request() req: RequestWithUser): Promise<Notification[]> {
    return this.notificationService.findAllUserNotifications(req.user.userId);
  }

  /**
   * Retorna a contagem de notificações não lidas (GET /notifications/unread-count).
   */
  @Get('unread-count')
  async getUnreadCount(@Request() req: RequestWithUser): Promise<number> {
    return this.notificationService.getUnreadCount(req.user.userId);
  }

  /**
   * Marca uma notificação específica como lida (PATCH /notifications/:id/read).
   */
  @HttpCode(HttpStatus.OK)
  @Patch(':id/read')
  async markAsRead(
    @Param('id') id: string,
    @Request() req: RequestWithUser,
  ): Promise<Notification> {
    // O service já verifica a posse antes de marcar como lida
    return this.notificationService.markAsRead(id, req.user.userId);
  }
}