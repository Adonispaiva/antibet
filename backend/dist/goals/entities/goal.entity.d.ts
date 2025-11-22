import { User } from '../../user/entities/user.entity';
export declare enum GoalType {
    FINANCIAL = "financial",
    EMOTIONAL = "emotional",
    TECHNICAL = "technical",
    OTHER = "other"
}
export declare class Goal {
    id: string;
    user: User;
    userId: string;
    title: string;
    description: string;
    type: GoalType;
    targetValue: number;
    currentValue: number;
    targetDate: Date;
    isCompleted: boolean;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
}
