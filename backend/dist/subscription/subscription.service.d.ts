import { Repository } from 'typeorm';
import { Subscription, SubscriptionStatus } from './entities/subscription.entity';
import { User, UserRole } from '../user/entities/user.entity';
export declare class SubscriptionService {
    private readonly subscriptionRepository;
    constructor(subscriptionRepository: Repository<Subscription>);
    findByUserId(userId: string): Promise<Subscription>;
    createOrUpdateSubscription(user: User, planId: string, gatewaySubscriptionId: string, periodEnd: Date, status: SubscriptionStatus, grantedRole: UserRole): Promise<Subscription>;
    updateSubscriptionStatus(gatewaySubscriptionId: string, newStatus: SubscriptionStatus, canceledAt?: Date | null): Promise<Subscription>;
}
