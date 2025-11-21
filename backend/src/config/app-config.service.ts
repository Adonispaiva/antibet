import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

/**
 * Interface que define as chaves de configuração esperadas,
 * fornecendo Tipagem (Type Safety) e documentação para o ambiente.
 */
export interface IAppConfig {
  NODE_ENV: string;
  PORT: number;
  CLIENT_URL: string;

  // Configurações do Banco de Dados (PostgreSQL)
  DB_HOST: string;
  DB_PORT: number;
  DB_USERNAME: string;
  DB_PASSWORD: string;
  DB_DATABASE: string;

  // Configurações de Autenticação (JWT)
  JWT_SECRET: string;
  JWT_EXPIRATION_TIME: string;

  // Configurações do Gateway de Pagamento (Stripe)
  STRIPE_SECRET_KEY: string;
  STRIPE_WEBHOOK_SECRET: string;
}

@Injectable()
export class AppConfigService implements IAppConfig {
  constructor(private configService: ConfigService) {}

  // --- Propriedades de Sistema ---
  get NODE_ENV(): string {
    return this.configService.get<string>('NODE_ENV', 'development');
  }

  get PORT(): number {
    return this.configService.get<number>('PORT', 3000);
  }

  get CLIENT_URL(): string {
    return this.configService.get<string>('CLIENT_URL', 'http://localhost:3001'); // Assumindo porta 3001 para o App (ex: Flutter Web)
  }

  // --- Propriedades do Banco de Dados ---
  get DB_HOST(): string {
    return this.configService.get<string>('DB_HOST', 'localhost');
  }

  get DB_PORT(): number {
    return this.configService.get<number>('DB_PORT', 5432);
  }

  get DB_USERNAME(): string {
    return this.configService.get<string>('DB_USERNAME', 'adonisp');
  }

  get DB_PASSWORD(): string {
    return this.configService.get<string>('DB_PASSWORD', '');
  }

  get DB_DATABASE(): string {
    return this.configService.get<string>('DB_DATABASE', 'antibet_db');
  }

  // --- Propriedades de Autenticação ---
  get JWT_SECRET(): string {
    const secret = this.configService.get<string>('JWT_SECRET');
    if (!secret) {
      throw new Error('JWT_SECRET nao esta configurado no .env!');
    }
    return secret;
  }

  get JWT_EXPIRATION_TIME(): string {
    return this.configService.get<string>('JWT_EXPIRATION_TIME', '3600s');
  }

  // --- Propriedades do Gateway de Pagamento (Stripe) ---
  get STRIPE_SECRET_KEY(): string {
    const secret = this.configService.get<string>('STRIPE_SECRET_KEY');
    if (!secret) {
      throw new Error('STRIPE_SECRET_KEY nao esta configurado no .env!');
    }
    return secret;
  }

  get STRIPE_WEBHOOK_SECRET(): string {
    const secret = this.configService.get<string>('STRIPE_WEBHOOK_SECRET');
    if (!secret) {
      throw new Error('STRIPE_WEBHOOK_SECRET nao esta configurado no .env!');
    }
    return secret;
  }
}