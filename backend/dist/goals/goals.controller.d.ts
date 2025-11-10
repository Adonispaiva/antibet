import { GoalsService } from './goals.service';
import { CreateGoalDto } from './dto/create-goal.dto';
import { UpdateGoalDto } from './dto/update-goal.dto';
import { AuthenticatedRequest } from '../auth/interfaces/authenticated-request.interface';
export declare class GoalsController {
    private readonly goalsService;
    constructor(goalsService: GoalsService);
    create(req: AuthenticatedRequest, createGoalDto: CreateGoalDto): Promise<import("./entities/goal.entity").Goal>;
    findAll(req: AuthenticatedRequest): Promise<import("./entities/goal.entity").Goal[]>;
    update(req: AuthenticatedRequest, goalId: string, updateGoalDto: UpdateGoalDto): Promise<import("./entities/goal.entity").Goal>;
    remove(req: AuthenticatedRequest, goalId: string): Promise<void>;
}
