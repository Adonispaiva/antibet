import { AiChatService } from './ai-chat.service';
import { AiChatMessageDto } from './dto/ai-chat-message.dto';
export declare class AiChatController {
    private readonly aiChatService;
    constructor(aiChatService: AiChatService);
    sendMessage(dto: AiChatMessageDto, req: any): Promise<any>;
}
