import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
export declare class AuthController {
    private readonly authService;
    constructor(authService: AuthService);
    login(loginDto: LoginDto): Promise<{
        user: Omit<import("../user/user.entity").User, "passwordHash">;
        accessToken: string;
    }>;
    register(registerDto: RegisterDto): Promise<{
        user: Omit<import("../user/user.entity").User, "passwordHash">;
        accessToken: string;
    }>;
}
