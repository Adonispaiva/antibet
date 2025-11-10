import { JwtService } from '@nestjs/jwt';
import { UserService } from '../user/user.service';
import { AuthRegisterDto } from './dto/auth-register.dto';
import { AuthLoginDto } from './dto/auth-login.dto';
export declare class AuthService {
    private userService;
    private jwtService;
    constructor(userService: UserService, jwtService: JwtService);
    private hashPassword;
    private comparePassword;
    register(registerDto: AuthRegisterDto): Promise<{
        accessToken: string;
        user: {
            id: any;
            email: any;
            name: any;
        };
    }>;
    login(loginDto: AuthLoginDto): Promise<{
        accessToken: string;
        user: {
            id: any;
            email: any;
            name: any;
        };
    }>;
    getProfile(userId: string): Promise<{
        id: any;
        email: any;
        name: any;
        plan: {
            id: any;
            name: any;
            price: any;
        };
    }>;
}
