import { AiChatService } from './ai-chat.service';
import { CreateChatMessageDto } from './dto/create-chat-message.dto';
import { ChatMessage } from './entities/chat-message.entity';
interface RequestWithUser extends Request {
    user: {
        userId: string;
        email: string;
        role: string;
    };
}
export declare class AiChatController {
    private readonly aiChatService;
    constructor(aiChatService: AiChatService);
    sendMessage(req: RequestWithUser, createChatMessageDto: CreateChatMessageDto): Promise<ChatMessage>;
    getHistory(req: RequestWithUser): Promise<ChatMessage[]>;
}
export {};
