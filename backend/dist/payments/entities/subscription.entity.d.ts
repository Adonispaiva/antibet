import { User } from '../../user/entities/user.entity';
export declare class Subscription {
    id: number;
    userId: number;
    user: User;
    planId: number;
    status: string;
    isActive: boolean;
    gatewaySubscriptionId: string;
    startDate: Date;
    endDate: Date;
    nextBillingDate: Date;
    createdAt: Date;
    updatedAt: Date;
}
