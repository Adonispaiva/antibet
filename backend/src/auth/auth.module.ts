import { Module } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport';
import { JwtModule } from '@nestjs/jwt';

// Módulos internos
import { UserModule } from '../user/user.module';
import { AppConfigurationModule } from '../config/config.module';
import { AppConfigService } from '../config/app-config.service';

// Serviços e Estratégias
import { AuthService } from './auth.service';
import { LocalStrategy } from './strategies/local.strategy';
import { JwtStrategy } from './strategies/jwt.strategy';

@Module({
  imports: [
    UserModule,
    PassportModule.register({ defaultStrategy: 'jwt' }),
    AppConfigurationModule,
    JwtModule.registerAsync({
      imports: [AppConfigurationModule],
      inject: [AppConfigService],
      useFactory: async (configService: AppConfigService) => ({
        secret: configService.JWT_SECRET,
        signOptions: {
          expiresIn: configService.JWT_EXPIRATION_TIME,
        },
      }),
    }),
  ],
  controllers: [],
  providers: [
    // 1. Serviço de Autenticação
    AuthService,
    // 2. Estratégias de Autenticação
    LocalStrategy, // Validação de login (email/senha)
    JwtStrategy,   // Validação de token
  ],
  exports: [
    // Exportamos o JwtModule, PassportModule e o AuthService
    JwtModule,
    PassportModule,
    AuthService, // Exportado para testes ou uso em outros módulos de domínio.
  ],
})
export class AuthModule {}