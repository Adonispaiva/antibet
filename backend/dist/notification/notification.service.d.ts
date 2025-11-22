import { Repository } from 'typeorm';
import { Notification } from './entities/notification.entity';
import { User } from '../../user/entities/user.entity';
import { NotificationType } from './entities/notification.entity';
export declare class NotificationService {
    private readonly notificationRepository;
    constructor(notificationRepository: Repository<Notification>);
    createNotification(recipient: User, title: string, message: string, type: NotificationType, metadata?: any): Promise<Notification>;
    findAllUserNotifications(recipientId: string): Promise<Notification[]>;
    markAsRead(id: string, recipientId: string): Promise<Notification>;
    getUnreadCount(recipientId: string): Promise<number>;
}
