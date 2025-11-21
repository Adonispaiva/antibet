import { Controller, Request, Post, UseGuards, Body, HttpCode, HttpStatus } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { AuthService } from './auth.service';

// Importando os DTOs
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { AuthResponseDto } from './dto/auth-response.dto';

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  /**
   * Endpoint de Login (POST /auth/login)
   * Utiliza o 'local' AuthGuard (que invoca a LocalStrategy)
   * para validar as credenciais antes de executar o metodo.
   * O LoginDto valida o corpo da requisicao.
   */
  @HttpCode(HttpStatus.OK)
  @UseGuards(AuthGuard('local'))
  @Post('login')
  async login(@Request() req: any, @Body() loginDto: LoginDto): Promise<AuthResponseDto> {
    // O @Body() loginDto esta aqui para validacao via DTO,
    // mas o req.user ja foi populado pelo AuthGuard('local')
    return this.authService.login(req.user);
  }

  /**
   * Endpoint de Registro (POST /auth/register)
   * Utiliza o RegisterDto para validar o corpo da requisicao.
   */
  @HttpCode(HttpStatus.CREATED)
  @Post('register')
  async register(@Body() registerDto: RegisterDto): Promise<AuthResponseDto> {
    return this.authService.register(registerDto);
  }
}