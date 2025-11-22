import { NotificationService } from './notification.service';
import { Notification } from './entities/notification.entity';
interface RequestWithUser extends Request {
    user: {
        userId: string;
        email: string;
        role: string;
    };
}
export declare class NotificationController {
    private readonly notificationService;
    constructor(notificationService: NotificationService);
    findAll(req: RequestWithUser): Promise<Notification[]>;
    getUnreadCount(req: RequestWithUser): Promise<number>;
    markAsRead(id: string, req: RequestWithUser): Promise<Notification>;
}
export {};
