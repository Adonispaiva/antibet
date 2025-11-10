import { Injectable, UnauthorizedException, BadRequestException, InternalServerErrorException } from '@nestjs/common';
import { UserService } from '../user/user.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { RegisterDto } from './dto/register.dto';
import { User } from '../user/user.entity';

@Injectable()
export class AuthService {
  constructor(
    private userService: UserService,
    private jwtService: JwtService,
  ) {}

  /**
   * 1. Valida as credenciais do usuário.
   * @returns O usuário (sem hash de senha) e o token.
   */
  async validateUser(email: string, pass: string): Promise<{ user: Omit<User, 'passwordHash'>, accessToken: string }> {
    // findByEmail carregará o passwordHash (select: false na entity)
    const user = await this.userService.findByEmail(email); 

    if (!user) {
      throw new UnauthorizedException('Credenciais inválidas: Usuário não encontrado.');
    }

    // Compara a senha fornecida com o hash do DB
    const isPasswordMatch = await bcrypt.compare(pass, user.passwordHash);

    if (!isPasswordMatch) {
      throw new UnauthorizedException('Credenciais inválidas: Senha incorreta.');
    }

    // Remove o hash de senha antes de retornar ao cliente
    const { passwordHash, ...safeUser } = user; 
    
    // Gera o token (payload contém o id)
    const payload = { email: user.email, sub: user.id };
    const accessToken = this.jwtService.sign(payload);

    return {
      user: safeUser as Omit<User, 'passwordHash'>,
      accessToken,
    };
  }

  /**
   * 2. Registra um novo usuário e o autentica (gera token).
   */
  async register(registrationData: RegisterDto): Promise<{ user: Omit<User, 'passwordHash'>, accessToken: string }> {
    // Verifica se o usuário já existe antes de criar
    const existingUser = await this.userService.findByEmail(registrationData.email);
    if (existingUser) {
      throw new BadRequestException('O e-mail já está em uso.');
    }

    try {
      // Cria o usuário (o UserService já trata o hashing da senha)
      const newUser = await this.userService.create(registrationData);
      
      // Gera o token
      const payload = { email: newUser.email, sub: newUser.id };
      const accessToken = this.jwtService.sign(payload);

      // Remove o hash antes de retornar
      const { passwordHash, ...safeUser } = newUser;

      return {
        user: safeUser as Omit<User, 'passwordHash'>,
        accessToken,
      };

    } catch (error) {
      throw new InternalServerErrorException('Falha no registro do usuário.');
    }
  }

  // Métodos de JWT Strategy (para JwtStrategy)
  async validateTokenPayload(payload: { sub: string, email: string }): Promise<User | null> {
    return this.userService.findProfile(payload.sub);
  }
}