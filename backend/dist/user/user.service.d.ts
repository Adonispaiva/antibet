import { Repository } from 'typeorm';
import { User, UserRole } from './entities/user.entity';
export declare class UserService {
    private readonly userRepository;
    constructor(userRepository: Repository<User>);
    create(createUserDto: any): Promise<User>;
    findAll(): Promise<User[]>;
    findOne(id: string): Promise<User | undefined>;
    findOneByEmail(email: string): Promise<User | undefined>;
    updateUserRole(userId: string, newRole: UserRole): Promise<User>;
}
