import { UserService } from '../user/user.service';
import { JwtService } from '@nestjs/jwt';
import { RegisterDto } from './dto/register.dto';
import { User } from '../user/user.entity';
export declare class AuthService {
    private userService;
    private jwtService;
    constructor(userService: UserService, jwtService: JwtService);
    validateUser(email: string, pass: string): Promise<{
        user: Omit<User, 'passwordHash'>;
        accessToken: string;
    }>;
    register(registrationData: RegisterDto): Promise<{
        user: Omit<User, 'passwordHash'>;
        accessToken: string;
    }>;
    validateTokenPayload(payload: {
        sub: string;
        email: string;
    }): Promise<User | null>;
}
