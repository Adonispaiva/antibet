import { GoalType } from '../entities/goal.entity';
export declare class CreateGoalDto {
    title: string;
    description?: string;
    type?: GoalType;
    targetValue: number;
    targetDate?: string;
}
