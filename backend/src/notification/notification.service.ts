// backend/src/notification/notification.service.ts

import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, UpdateResult } from 'typeorm';
import { Notification } from './entities/notification.entity';
import { CreateNotificationDto } from './dto/create-notification.dto';
import { UpdateNotificationDto } from './dto/update-notification.dto';

@Injectable()
export class NotificationService {
  constructor(
    @InjectRepository(Notification)
    private readonly notificationRepository: Repository<Notification>,
  ) {}

  /**
   * Cria uma nova notificação para o usuário especificado (usado por outros serviços).
   * @param createNotificationDto Os dados validados da notificação.
   * @param userId O ID do usuário logado.
   * @returns A entidade de Notification salva.
   */
  async create(
    createNotificationDto: CreateNotificationDto,
    userId: number,
  ): Promise<Notification> {
    const newNotification = this.notificationRepository.create({
      ...createNotificationDto,
      userId,
      isRead: false, // Força 'não lida' na criação
    });

    return this.notificationRepository.save(newNotification);
  }

  /**
   * Obtém todas as notificações do usuário logado.
   * @param userId O ID do usuário logado.
   * @returns Uma lista de notificações, ordenada da mais recente para a mais antiga.
   */
  async findAll(userId: number): Promise<Notification[]> {
    return this.notificationRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Atualiza uma notificação específica (principalmente o status isRead), garantindo a posse.
   * @param id O ID da notificação.
   * @param updateNotificationDto Os dados a serem atualizados (ex: { isRead: true }).
   * @param userId O ID do usuário logado.
   * @returns A entidade de Notification atualizada.
   */
  async update(
    id: number,
    updateNotificationDto: UpdateNotificationDto,
    userId: number,
  ): Promise<Notification> {
    // Primeiro, verifica se a notificação existe e pertence ao usuário
    const notification = await this.notificationRepository.findOne({
        where: { id, userId },
    });

    if (!notification) {
        throw new NotFoundException(`Notificação com ID "${id}" não encontrada ou não pertence ao usuário.`);
    }

    // Aplica as atualizações do DTO e salva
    Object.assign(notification, updateNotificationDto);
    return this.notificationRepository.save(notification);
  }
  
  /**
   * Marca todas as notificações do usuário como lidas.
   * @param userId O ID do usuário logado.
   * @returns O resultado da operação de atualização em massa.
   */
  async markAllAsRead(userId: number): Promise<UpdateResult> {
      return this.notificationRepository.update(
          { userId, isRead: false }, // Condição: apenas as não lidas
          { isRead: true } // O que será atualizado
      );
  }

  /**
   * Remove uma notificação específica, garantindo a posse.
   * @param id O ID da notificação.
   * @param userId O ID do usuário logado.
   */
  async remove(id: number, userId: number): Promise<void> {
    const result = await this.notificationRepository.delete({ id, userId });

    if (result.affected === 0) {
      throw new NotFoundException(`Notificação com ID "${id}" não encontrada ou não pertence ao usuário.`);
    }
  }
}