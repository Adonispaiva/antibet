import { User } from '../user/user.entity';
export declare class AiInteractionLog {
    id: string;
    userId: string;
    user: User;
    prompt: string;
    response: string;
    modelId: string;
    inputTokens: number;
    outputTokens: number;
    costUsd: number;
    timestamp: Date;
}
