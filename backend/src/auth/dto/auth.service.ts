import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';

import { UserService } from '../user/user.service';
import { RegisterDto } from './dto/register.dto';
import { AuthResponseDto } from './dto/auth-response.dto';
import { User, UserRole } from '../user/entities/user.entity';

@Injectable()
export class AuthService {
  private readonly saltRounds = 10;

  constructor(
    private userService: UserService,
    private jwtService: JwtService,
  ) {}

  /**
   * Valida as credenciais de um usuário (usado pela Local Strategy)
   * @param email Email do usuário
   * @param pass Senha em texto simples
   * @returns O objeto do usuário sem a senha, ou null/UnauthorizedException
   */
  async validateUser(email: string, pass: string): Promise<any> {
    const user = await this.userService.findOneByEmail(email);

    if (user && (await bcrypt.compare(pass, user.password))) {
      // Retorna o usuário sem a senha para evitar vazamento
      const { password, ...result } = user;
      return result;
    }
    return null;
  }

  /**
   * Executa o processo de login e gera o token JWT.
   * @param user Objeto do usuário validado.
   * @returns Objeto contendo o access_token e o usuário.
   */
  async login(user: any): Promise<AuthResponseDto> {
    // Payload (dados que serão codificados no token)
    const payload = {
      email: user.email,
      sub: user.id,
      role: user.role,
    };

    const userData = {
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      role: user.role,
    };

    return {
      user: userData,
      access_token: this.jwtService.sign(payload),
    };
  }

  /**
   * Registra um novo usuário no sistema.
   * @param registerDto DTO contendo os dados do novo usuário.
   * @returns O usuário recém-criado e um token de acesso.
   */
  async register(registerDto: RegisterDto): Promise<AuthResponseDto> {
    // 1. Verificar se o usuário já existe
    const existingUser = await this.userService.findOneByEmail(registerDto.email);
    if (existingUser) {
      throw new ConflictException('O email fornecido ja esta em uso.');
    }

    // 2. Hash da senha
    const hashedPassword = await bcrypt.hash(registerDto.password, this.saltRounds);

    // 3. Criação do objeto de usuário
    const newUser = await this.userService.create({
      ...registerDto,
      password: hashedPassword,
      role: UserRole.BASIC, // Definindo o papel padrão
    });

    // 4. Logar o usuário recém-criado e retornar o token
    // (Removemos a senha do objeto antes de passar para o login)
    const { password, ...result } = newUser;
    return this.login(result);
  }
}