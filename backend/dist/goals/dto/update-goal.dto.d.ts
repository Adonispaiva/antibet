import { CreateGoalDto } from './create-goal.dto';
import { GoalType } from '../entities/goal.entity';
declare const UpdateGoalDto_base: import("@nestjs/mapped-types").MappedType<Partial<CreateGoalDto>>;
export declare class UpdateGoalDto extends UpdateGoalDto_base {
    title?: string;
    description?: string;
    type?: GoalType;
    targetValue?: number;
    currentValue?: number;
    targetDate?: string;
    isCompleted?: boolean;
}
export {};
