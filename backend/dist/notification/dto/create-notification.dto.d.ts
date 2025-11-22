import { NotificationType } from '../entities/notification.entity';
export declare class CreateNotificationDto {
    recipientId: string;
    title: string;
    message: string;
    type?: NotificationType;
    metadata?: any;
}
