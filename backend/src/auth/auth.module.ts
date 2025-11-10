import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { UserModule } from '../user/user.module';
import { PassportModule } from '@nestjs/passport';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config'; // Importa ConfigModule e ConfigService
import { JwtStrategy } from './strategies/jwt.strategy'; // NOVO
import { JwtAuthGuard } from './guards/jwt-auth.guard'; // NOVO

@Module({
  imports: [
    UserModule,
    PassportModule,
    // CRÍTICO: Configuração Assíncrona para ler o .env com segurança
    JwtModule.registerAsync({
      imports: [ConfigModule], // Importa o módulo de Configuração
      useFactory: async (configService: ConfigService) => ({
        secret: configService.get('JWT_SECRET'), // Lê a chave secreta
        signOptions: { expiresIn: '60m' }, // Token expira em 60 minutos
      }),
      inject: [ConfigService], // Injeta o ConfigService na factory
    }),
  ],
  controllers: [AuthController],
  providers: [
    AuthService,
    // Registra a Strategy e o Guard para o Passport.
    JwtStrategy, 
    JwtAuthGuard,
  ],
  exports: [
    AuthService, 
    JwtModule, 
    JwtAuthGuard
  ],
})
export class AuthModule {}