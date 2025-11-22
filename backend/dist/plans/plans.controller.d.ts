import { PlansService } from './plans.service';
import { Plan } from './entities/plan.entity';
export declare class PlansController {
    private readonly plansService;
    constructor(plansService: PlansService);
    findAllActivePlans(): Promise<Plan[]>;
    findOne(id: string): Promise<Plan>;
}
