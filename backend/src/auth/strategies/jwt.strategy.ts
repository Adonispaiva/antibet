import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { AppConfigService } from '../../config/app-config.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    private readonly configService: AppConfigService,
  ) {
    super({
      // Define como o token será extraído da requisição:
      // Padrão: 'Authorization: Bearer <token>'
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      
      // Ignora a expiração se o token estiver expirado (false = não ignora)
      ignoreExpiration: false,
      
      // A chave secreta usada para verificar a assinatura do token
      secretOrKey: configService.JWT_SECRET,
    });
  }

  /**
   * Este método é chamado pelo Passport após o token ser
   * verificado (assinatura e expiração).
   * O payload é o objeto que foi codificado no AuthService.
   * @param payload O conteúdo decodificado do token JWT.
   * @returns O objeto que será anexado ao request.user
   */
  async validate(payload: any) {
    // O Passport anexará este retorno ao request.user
    return { 
      userId: payload.sub, 
      email: payload.email, 
      role: payload.role 
    };
  }
}