// backend/src/auth/jwt.strategy.ts

import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config'; // Assumindo que o ConfigModule está configurado
import { InjectRepository } from '@nestjs/typeorm'; // Assumindo TypeORM/Repository
import { Repository } from 'typeorm';

import { JwtPayload } from './interfaces/jwt-payload.interface'; // A interface criada
import { User } from '../user/entities/user.entity'; // Assumindo o modelo de Entidade do Usuário

/**
 * Estratégia de Autenticação JWT.
 * * Herda de PassportStrategy e utiliza o nome 'jwt' para ser referenciada pelo AuthGuard.
 * É responsável por extrair, validar e decodificar o token JWT.
 */
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy, 'jwt') {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    configService: ConfigService, // Injeta o serviço de configuração
  ) {
    super({
      // 1. Extrai o token do header de autorização como Bearer Token
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(), 
      
      // 2. Garante que o JWT é assinado usando o mesmo segredo (chave privada)
      secretOrKey: configService.get<string>('JWT_SECRET'), // Pega a chave do .env
      
      // Opcional: Define se o token de expiração (exp) deve ser ignorado. Deve ser false para segurança.
      ignoreExpiration: false, 
    });
  }

  /**
   * Método de validação chamado após o token ser decodificado e verificado.
   * * @param payload O payload decodificado do JWT (conforme JwtPayload interface).
   * @returns O objeto de usuário que será anexado à requisição (req.user).
   * @throws UnauthorizedException se o usuário não for encontrado.
   */
  async validate(payload: JwtPayload): Promise<User> {
    const { id, email } = payload;
    
    // Busca o usuário no banco de dados para garantir que a conta ainda está ativa e existe.
    // Melhoria de segurança: evita que tokens de usuários deletados continuem válidos.
    const user = await this.userRepository.findOne({ where: { id, email } }); 

    if (!user) {
      throw new UnauthorizedException('Token inválido ou usuário não encontrado.');
    }

    // Retorna a entidade completa do usuário.
    // Isso anexa a entidade do usuário ao objeto de requisição (req.user)
    return user; 
  }
}