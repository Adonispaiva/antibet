import { StrategyFocus } from '../entities/strategy.entity';
export declare class CreateStrategyDto {
    name: string;
    description?: string;
    focus?: StrategyFocus;
    riskPerTrade?: number;
    targetWinRate?: number;
}
