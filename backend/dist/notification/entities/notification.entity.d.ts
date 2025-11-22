import { User } from '../../user/entities/user.entity';
export declare enum NotificationType {
    GOAL_ALERT = "goal_alert",
    PAYMENT_STATUS = "payment_status",
    SYSTEM_UPDATE = "system_update",
    AI_RECOMMENDATION = "ai_recommendation",
    SUBSCRIPTION_END = "subscription_end"
}
export declare class Notification {
    id: string;
    recipient: User;
    recipientId: string;
    title: string;
    message: string;
    type: NotificationType;
    metadata: any;
    isRead: boolean;
    createdAt: Date;
}
