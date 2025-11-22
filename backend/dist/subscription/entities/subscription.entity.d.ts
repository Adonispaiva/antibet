import { User, UserRole } from '../../user/entities/user.entity';
export declare enum SubscriptionStatus {
    ACTIVE = "active",
    CANCELED = "canceled",
    INACTIVE = "inactive",
    PAST_DUE = "past_due",
    TRIALING = "trialing"
}
export declare class Subscription {
    id: string;
    user: User;
    userId: string;
    paymentGatewaySubscriptionId: string;
    status: SubscriptionStatus;
    currentRole: UserRole;
    planId: string;
    currentPeriodEnd: Date;
    canceledAt: Date;
    createdAt: Date;
    updatedAt: Date;
}
