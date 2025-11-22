import { User } from '../../user/entities/user.entity';
import { AiChatMessage } from './ai-chat-message.entity';
export declare class AiChatConversation {
    id: number;
    userId: number;
    user: User;
    messages: AiChatMessage[];
    isArchived: boolean;
    title: string;
    createdAt: Date;
    updatedAt: Date;
}
