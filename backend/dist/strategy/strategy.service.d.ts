import { Repository } from 'typeorm';
import { Strategy } from './entities/strategy.entity';
import { User } from '../../user/entities/user.entity';
export declare class StrategiesService {
    private readonly strategyRepository;
    constructor(strategyRepository: Repository<Strategy>);
    createStrategy(user: User, createStrategyDto: any): Promise<Strategy>;
    findAllUserStrategies(userId: string): Promise<Strategy[]>;
    findOneStrategy(id: string, userId: string): Promise<Strategy>;
    updateStrategy(strategy: Strategy, updateStrategyDto: any): Promise<Strategy>;
    removeStrategy(id: string, userId: string): Promise<void>;
}
