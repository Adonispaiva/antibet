import { StrategiesService } from './strategies.service';
import { CreateStrategyDto } from './dto/create-strategy.dto';
import { UpdateStrategyDto } from './dto/update-strategy.dto';
import { Strategy } from './entities/strategy.entity';
interface RequestWithUser extends Request {
    user: {
        userId: string;
        email: string;
        role: string;
    };
}
export declare class StrategiesController {
    private readonly strategiesService;
    constructor(strategiesService: StrategiesService);
    create(req: RequestWithUser, createStrategyDto: CreateStrategyDto): Promise<Strategy>;
    findAll(req: RequestWithUser): Promise<Strategy[]>;
    findOne(id: string, req: RequestWithUser): Promise<Strategy>;
    update(id: string, req: RequestWithUser, updateStrategyDto: UpdateStrategyDto): Promise<Strategy>;
    remove(id: string, req: RequestWithUser): Promise<void>;
}
export {};
