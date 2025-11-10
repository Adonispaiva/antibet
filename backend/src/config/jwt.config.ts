import { registerAs } from '@nestjs/config';
import { JwtModuleOptions } from '@nestjs/jwt';

const jwtConfig = registerAs('jwt', (): JwtModuleOptions => ({
  secret: process.env.JWT_SECRET, // Chave secreta
  signOptions: {
    expiresIn: process.env.JWT_EXPIRES_IN, // Tempo de expiração (ex: 3600s)
  },
}));

export default jwtConfig;