import { RawBodyRequest } from '@nestjs/common';
import { PaymentsService } from './payments.service';
import { CreateCheckoutSessionDto } from './dto/create-checkout-session.dto';
interface RequestWithUser extends Request {
    user: {
        userId: string;
        email: string;
        role: string;
    };
}
export declare class PaymentsController {
    private readonly paymentsService;
    constructor(paymentsService: PaymentsService);
    createCheckoutSession(req: RequestWithUser, createCheckoutSessionDto: CreateCheckoutSessionDto): Promise<{
        url: string;
    }>;
    handleStripeWebhook(req: RawBodyRequest<Request>): Promise<{
        received: boolean;
    }>;
    getSubscriptionStatus(req: RequestWithUser): Promise<any>;
}
export {};
