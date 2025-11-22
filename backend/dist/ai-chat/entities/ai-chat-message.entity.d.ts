import { User } from '../../user/entities/user.entity';
export declare enum MessageRole {
    USER = "user",
    ASSISTANT = "assistant",
    SYSTEM = "system"
}
export declare class ChatMessage {
    id: string;
    user: User;
    userId: string;
    role: MessageRole;
    content: string;
    cost: number;
    aiMetadata: any;
    createdAt: Date;
}
