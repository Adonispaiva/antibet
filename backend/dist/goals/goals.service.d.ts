import { Repository } from 'typeorm';
import { Goal } from './entities/goal.entity';
import { User } from '../../user/entities/user.entity';
export declare class GoalsService {
    private readonly goalRepository;
    constructor(goalRepository: Repository<Goal>);
    createGoal(user: User, createGoalDto: any): Promise<Goal>;
    findAllUserGoals(userId: string): Promise<Goal[]>;
    findOneGoal(id: string, userId: string): Promise<Goal>;
    updateGoal(goal: Goal, updateGoalDto: any): Promise<Goal>;
    removeGoal(id: string, userId: string): Promise<void>;
}
