import { User } from '../../user/entities/user.entity';
export declare enum PaymentStatus {
    PENDING = "pending",
    COMPLETED = "completed",
    FAILED = "failed",
    REFUNDED = "refunded"
}
export declare enum PaymentGateway {
    STRIPE = "stripe",
    PAGSEGURO = "pagseguro",
    MERCADOPAGO = "mercadopago",
    MANUAL = "manual"
}
export declare class PaymentLog {
    id: string;
    user: User;
    userId: string;
    transactionId: string;
    gateway: PaymentGateway;
    status: PaymentStatus;
    amount: number;
    currency: string;
    planId: string;
    gatewayPayload: any;
    createdAt: Date;
    updatedAt: Date;
}
