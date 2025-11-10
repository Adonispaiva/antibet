import { Repository } from 'typeorm';
import { Goal } from './entities/goal.entity';
import { CreateGoalDto } from './dto/create-goal.dto';
import { UpdateGoalDto } from './dto/update-goal.dto';
export declare class GoalsService {
    private readonly goalRepository;
    constructor(goalRepository: Repository<Goal>);
    createGoal(userId: string, createDto: CreateGoalDto): Promise<Goal>;
    findGoalsByUserId(userId: string): Promise<Goal[]>;
    private findOneOrFail;
    updateGoal(userId: string, goalId: string, updateDto: UpdateGoalDto): Promise<Goal>;
    deleteGoal(userId: string, goalId: string): Promise<void>;
}
