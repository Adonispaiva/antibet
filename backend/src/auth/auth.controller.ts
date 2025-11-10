import { Controller, Post, Body, UsePipes, ValidationPipe } from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto'; // Importação do DTO de Login
import { RegisterDto } from './dto/register.dto'; // Importação do DTO de Registro
// import { RegisterDto, LoginDto } from './dto'; // Importação ideal

@Controller('auth')
// Recomenda-se configurar o ValidationPipe globalmente no main.ts, mas 
// o aplicamos aqui para garantir que o Controller utilize os DTOs.
@UsePipes(new ValidationPipe({ whitelist: true, transform: true }))
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  /**
   * Rota de Login. O corpo é validado pelo LoginDto.
   */
  @Post('login')
  async login(@Body() loginDto: LoginDto) {
    const { email, password } = loginDto;
    return this.authService.validateUser(email, password);
  }

  /**
   * Rota de Registro. O corpo é validado pelo RegisterDto.
   */
  @Post('register')
  async register(@Body() registerDto: RegisterDto) {
    // O service deve lidar com o hashing da senha e a criação do usuário
    return this.authService.register(registerDto);
  }
}