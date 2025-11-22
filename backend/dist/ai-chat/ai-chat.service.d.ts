import { Repository } from 'typeorm';
import { AppConfigService } from '../../config/app-config.service';
import { ChatMessage } from './entities/chat-message.entity';
import { CreateChatMessageDto } from './dto/create-chat-message.dto';
import { User } from '../../user/entities/user.entity';
export declare class AiChatService {
    private readonly chatMessageRepository;
    private readonly configService;
    private readonly AI_MODEL;
    private readonly API_URL;
    constructor(chatMessageRepository: Repository<ChatMessage>, configService: AppConfigService);
    getChatHistory(userId: string): Promise<ChatMessage[]>;
    processUserMessage(user: User, createChatMessageDto: CreateChatMessageDto): Promise<ChatMessage>;
    private saveMessage;
    private callAIModel;
}
