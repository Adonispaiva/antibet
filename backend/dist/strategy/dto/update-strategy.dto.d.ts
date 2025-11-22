import { CreateStrategyDto } from './create-strategy.dto';
import { StrategyFocus } from '../entities/strategy.entity';
declare const UpdateStrategyDto_base: import("@nestjs/mapped-types").MappedType<Partial<CreateStrategyDto>>;
export declare class UpdateStrategyDto extends UpdateStrategyDto_base {
    name?: string;
    description?: string;
    focus?: StrategyFocus;
    riskPerTrade?: number;
    targetWinRate?: number;
}
export {};
