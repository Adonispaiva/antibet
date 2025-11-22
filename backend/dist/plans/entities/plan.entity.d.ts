import { UserRole } from '../../user/entities/user.entity';
export declare enum PlanInterval {
    MONTHLY = "month",
    YEARLY = "year"
}
export declare class Plan {
    id: string;
    name: string;
    description: string;
    price: number;
    interval: PlanInterval;
    grantedRole: UserRole;
    features: string[];
    paymentGatewayId: string;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
}
