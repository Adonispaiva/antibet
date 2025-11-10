import { AuthService } from './auth.service';
import { AuthRegisterDto } from './dto/auth-register.dto';
import { AuthenticatedRequest } from './interfaces/authenticated-request.interface';
import { AuthLoginDto } from './dto/auth-login.dto';
export declare class AuthController {
    private readonly authService;
    constructor(authService: AuthService);
    register(registerDto: AuthRegisterDto): Promise<{
        accessToken: string;
        user: {
            id: any;
            email: any;
            name: any;
        };
    }>;
    login(req: AuthenticatedRequest, _loginDto: AuthLoginDto): Promise<{
        accessToken: string;
        user: {
            id: any;
            email: any;
            name: any;
        };
    }>;
    getProfile(req: AuthenticatedRequest): Promise<{
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
