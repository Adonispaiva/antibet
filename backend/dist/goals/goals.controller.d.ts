import { GoalsService } from './goals.service';
import { CreateGoalDto } from './dto/create-goal.dto';
import { UpdateGoalDto } from './dto/update-goal.dto';
import { Goal } from './entities/goal.entity';
interface RequestWithUser extends Request {
    user: {
        userId: string;
        email: string;
        role: string;
    };
}
export declare class GoalsController {
    private readonly goalsService;
    constructor(goalsService: GoalsService);
    create(req: RequestWithUser, createGoalDto: CreateGoalDto): Promise<Goal>;
    findAll(req: RequestWithUser): Promise<Goal[]>;
    findOne(id: string, req: RequestWithUser): Promise<Goal>;
    update(id: string, req: RequestWithUser, updateGoalDto: UpdateGoalDto): Promise<Goal>;
    remove(id: string, req: RequestWithUser): Promise<void>;
}
export {};
