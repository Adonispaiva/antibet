// backend/src/notification/notification.controller.ts

import { 
  Controller, 
  Get, 
  Post, 
  Body, 
  Patch, 
  Delete, 
  UseGuards, 
  Req, 
  Param, 
  ParseIntPipe, 
  HttpCode, 
  HttpStatus 
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { Request } from 'express';

import { NotificationService } from './notification.service';
import { CreateNotificationDto } from './dto/create-notification.dto';
import { UpdateNotificationDto } from './dto/update-notification.dto';
import { User } from '../user/entities/user.entity'; // A Entidade de Usuário

/**
 * Interface customizada para a requisição com o objeto User injetado pelo JwtStrategy.
 */
interface RequestWithUser extends Request {
  user: User;
}

@Controller('notifications')
@UseGuards(AuthGuard('jwt')) // Protege todas as rotas deste controller
export class NotificationController {
  constructor(private readonly notificationService: NotificationService) {}

  /**
   * Cria uma nova notificação (tipicamente usado internamente por outros serviços, 
   * mas exposto para testes/administração).
   */
  @Post()
  create(
    @Body() createNotificationDto: CreateNotificationDto,
    @Req() req: RequestWithUser,
  ) {
    const userId = req.user.id;
    return this.notificationService.create(createNotificationDto, userId);
  }

  /**
   * Lista todas as notificações do usuário logado.
   */
  @Get()
  findAll(@Req() req: RequestWithUser) {
    const userId = req.user.id;
    return this.notificationService.findAll(userId);
  }

  /**
   * Atualiza o status de leitura de uma notificação específica.
   */
  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateNotificationDto: UpdateNotificationDto,
    @Req() req: RequestWithUser,
  ) {
    const userId = req.user.id;
    return this.notificationService.update(id, updateNotificationDto, userId);
  }
  
  /**
   * Atualiza o status de leitura de todas as notificações não lidas.
   */
  @Patch('read-all')
  @HttpCode(HttpStatus.OK)
  markAllAsRead(@Req() req: RequestWithUser) {
      const userId = req.user.id;
      return this.notificationService.markAllAsRead(userId);
  }

  /**
   * Remove uma notificação específica.
   */
  @Delete(':id')
  remove(
    @Param('id', ParseIntPipe) id: number,
    @Req() req: RequestWithUser,
  ) {
    const userId = req.user.id;
    return this.notificationService.remove(id, userId);
  }
}