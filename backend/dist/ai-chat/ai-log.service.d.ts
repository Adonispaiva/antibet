import { Repository } from 'typeorm';
import { AiInteractionLog } from './ai-log.entity';
export declare class AiLogService {
    private logRepository;
    constructor(logRepository: Repository<AiInteractionLog>);
    getDailyInteractionsCount(userId: string): Promise<number>;
    createLog(logData: Partial<AiInteractionLog>): Promise<AiInteractionLog>;
}
