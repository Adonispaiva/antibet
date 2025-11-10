import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';

// Payload esperado após a decodificação do token
interface JwtPayload {
  email: string;
  sub: string; // ID do usuário
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private configService: ConfigService) {
    super({
      // Extrai o token do cabeçalho de Autorização (Bearer Token)
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(), 
      // Garante que o token não expirou
      ignoreExpiration: false, 
      // Usa a chave secreta carregada do .env
      secretOrKey: configService.get<string>('JWT_SECRET'), 
    });
  }

  // Método de validação: chamado se o token for válido
  async validate(payload: JwtPayload) {
    // Aqui, em um projeto mais complexo, você faria uma busca no DB 
    // para garantir que o usuário (payload.sub) ainda existe e está ativo.
    
    // Por enquanto, apenas garantimos que o payload básico exista.
    if (!payload.sub) {
      throw new UnauthorizedException();
    }
    
    // Retorna o payload que será anexado ao objeto Request (req.user)
    return { userId: payload.sub, email: payload.email }; 
  }
}