import { Repository } from 'typeorm';
import { AppConfigService } from '../config/app-config.service';
import { PlansService } from '../plans/plans.service';
import { SubscriptionService } from '../subscription/subscription.service';
import { UserService } from '../user/user.service';
import { PaymentLog } from './entities/payment-log.entity';
import { Subscription } from '../subscription/entities/subscription.entity';
export declare class PaymentsService {
    private readonly paymentLogRepository;
    private readonly configService;
    private readonly plansService;
    private readonly subscriptionService;
    private readonly userService;
    private stripe;
    constructor(paymentLogRepository: Repository<PaymentLog>, configService: AppConfigService, plansService: PlansService, subscriptionService: SubscriptionService, userService: UserService);
    createCheckoutSession(userId: string, planId: string): Promise<{
        url: string;
    }>;
    handleStripeWebhook(signature: string, rawBody: Buffer): Promise<{
        received: boolean;
    }>;
    private fulfillCheckoutSession;
    getSubscriptionStatus(userId: string): Promise<Subscription>;
}
