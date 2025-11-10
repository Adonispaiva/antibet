import { PaymentsService } from './payments.service';
import { CreateCheckoutSessionDto } from './dto/create-checkout-session.dto';
import { AuthenticatedRequest } from '@/auth/interfaces/authenticated-request.interface';
export declare class PaymentsController {
    private readonly paymentsService;
    constructor(paymentsService: PaymentsService);
    createCheckoutSession(req: AuthenticatedRequest, createCheckoutSessionDto: CreateCheckoutSessionDto): Promise<{
        sessionId: string;
        url: string;
    }>;
    handleWebhook(req: AuthenticatedRequest): Promise<{
        received: boolean;
    }>;
}
