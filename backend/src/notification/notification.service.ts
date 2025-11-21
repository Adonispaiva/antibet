import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Notification } from './entities/notification.entity';
import { User } from '../../user/entities/user.entity';
import { NotificationType } from './entities/notification.entity';

@Injectable()
export class NotificationService {
  constructor(
    @InjectRepository(Notification)
    private readonly notificationRepository: Repository<Notification>,
  ) {}

  /**
   * Cria uma nova notificação para um usuário (geralmente chamada por outro service, ex: GoalsService).
   * @param recipient O objeto do usuário que receberá a notificação.
   * @param title O título da notificação.
   * @param message A mensagem completa.
   * @param type O tipo de notificação.
   * @param metadata Dados adicionais.
   * @returns A nova notificação.
   */
  async createNotification(
    recipient: User,
    title: string,
    message: string,
    type: NotificationType,
    metadata: any = null,
  ): Promise<Notification> {
    const newNotification = this.notificationRepository.create({
      recipient: recipient,
      recipientId: recipient.id,
      title: title,
      message: message,
      type: type,
      metadata: metadata,
      isRead: false,
    });
    
    return this.notificationRepository.save(newNotification);
  }

  /**
   * Retorna todas as notificações de um usuário.
   * @param recipientId O ID do usuário.
   * @returns Lista de notificações.
   */
  async findAllUserNotifications(recipientId: string): Promise<Notification[]> {
    return this.notificationRepository.find({
      where: { recipientId: recipientId },
      order: { createdAt: 'DESC' }, // Ordena da mais recente para a mais antiga
    });
  }

  /**
   * Marca uma notificação específica como lida.
   * @param id ID da notificação.
   * @param recipientId ID do usuário logado (para segurança).
   * @returns A notificação atualizada.
   */
  async markAsRead(id: string, recipientId: string): Promise<Notification> {
    const notification = await this.notificationRepository.findOne({
      where: { id: id, recipientId: recipientId },
    });
    
    if (!notification) {
      throw new NotFoundException('Notificacao nao encontrada ou nao pertence a este usuario.');
    }
    
    if (!notification.isRead) {
      notification.isRead = true;
      return this.notificationRepository.save(notification);
    }
    return notification;
  }

  /**
   * Retorna a contagem de notificações nao lidas.
   */
  async getUnreadCount(recipientId: string): Promise<number> {
    return this.notificationRepository.count({
      where: { recipientId: recipientId, isRead: false },
    });
  }
}