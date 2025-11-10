import { RawBodyRequest } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { User } from '@/user/entities/user.entity';
import { UserService } from '../user/user.service';
export declare class PaymentsService {
    private configService;
    private userService;
    private stripe;
    constructor(configService: ConfigService, userService: UserService);
    createCheckoutSession(user: User, planId: string): Promise<{
        sessionId: string;
        url: string;
    }>;
    handleWebhook(req: RawBodyRequest<any>): Promise<{
        received: boolean;
    }>;
}
