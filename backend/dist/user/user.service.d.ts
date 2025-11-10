import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { AuthRegisterDto } from '../auth/dto/auth-register.dto';
import { Plan } from '../plans/plans.entity';
export declare class UserService {
    private userRepository;
    private planRepository;
    constructor(userRepository: Repository<User>, planRepository: Repository<Plan>);
    findByEmail(email: string): Promise<User | undefined>;
    findById(id: string): Promise<User>;
    create(registerDto: AuthRegisterDto): Promise<User>;
    updateUserPlan(userId: string, stripePriceId: string, subscriptionId: string): Promise<User>;
}
