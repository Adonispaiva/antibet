import { Plan } from './entities/plan.entity';
import { Repository } from 'typeorm';
export declare class PlansService {
    private readonly planRepository;
    constructor(planRepository: Repository<Plan>);
    findAll(): Promise<Plan[]>;
    findPlanByUserId(userId: string): Promise<Plan>;
}
