import { Repository } from 'typeorm';
import { Plan } from './entities/plan.entity';
export declare class PlansService {
    private readonly planRepository;
    constructor(planRepository: Repository<Plan>);
    findAllActivePlans(): Promise<Plan[]>;
    findOne(id: string): Promise<Plan | undefined>;
    findByGatewayId(gatewayId: string): Promise<Plan | undefined>;
}
