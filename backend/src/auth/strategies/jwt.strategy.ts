import { ExtractJwt, Strategy } from 'passport-jwt';
import { PassportStrategy } from '@nestjs/passport';
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { UserService } from '../../user/user.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    private userService: UserService,
    configService: ConfigService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get('JWT_SECRET'), // Obtém o segredo do .env
    });
  }

  // Validação: Este método é chamado após o token ser validado
  async validate(payload: { sub: string; email: string }) {
    // payload.sub é o ID do usuário (definido no AuthService)
    const user = await this.userService.findProfile(payload.sub); 

    if (!user) {
      throw new UnauthorizedException();
    }
    // Retorna o usuário logado (disponível em req.user)
    return user; 
  }
}