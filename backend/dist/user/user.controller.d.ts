import { UserService } from './user.service';
import { User } from './entities/user.entity';
interface RequestWithUser extends Request {
    user: {
        userId: string;
        email: string;
        role: string;
    };
}
export declare class UserController {
    private readonly userService;
    constructor(userService: UserService);
    getProfile(req: RequestWithUser): Promise<Partial<User>>;
}
export {};
