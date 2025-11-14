import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

/**
 * Interface que define as chaves de configuração esperadas,
 * fornecendo Tipagem (Type Safety) e documentação para o ambiente.
 */
export interface IAppConfig {
  NODE_ENV: string;
  PORT: number;

  // Configurações do Banco de Dados (PostgreSQL)
  DB_HOST: string;
  DB_PORT: number;
  DB_USERNAME: string;
  DB_PASSWORD: string;
  DB_DATABASE: string;

  // Configurações de Autenticação (JWT)
  JWT_SECRET: string;
  JWT_EXPIRATION_TIME: string;
}

/**
 * Serviço responsável por fornecer acesso tipado e validado
 * às configurações de ambiente, lendo do ConfigService do NestJS.
 * Isso garante que o uso de variáveis de ambiente seja seguro e consistente.
 */
@Injectable()
export class AppConfigService implements IAppConfig {
  constructor(private configService: ConfigService) {
    // É uma boa prática adicionar validação aqui (ex: Joi)
    // para garantir que todas as variáveis críticas estejam presentes
    // na inicialização do serviço.
    // Por enquanto, confiamos no NestJS/TypeORM para lançar exceção
    // se o TypeOrmModule não conseguir se conectar.
  }

  // --- Propriedades de Sistema ---
  get NODE_ENV(): string {
    return this.configService.get<string>('NODE_ENV', 'development');
  }

  get PORT(): number {
    return this.configService.get<number>('PORT', 3000);
  }

  // --- Propriedades do Banco de Dados ---

  get DB_HOST(): string {
    return this.configService.get<string>('DB_HOST', 'localhost');
  }

  get DB_PORT(): number {
    // O fallback 5432 é o padrão do PostgreSQL.
    return this.configService.get<number>('DB_PORT', 5432);
  }

  get DB_USERNAME(): string {
    // O uso de 'adonisp' como fallback é temporário,
    // mas deve ser removido em produção.
    return this.configService.get<string>('DB_USERNAME', 'adonisp');
  }

  get DB_PASSWORD(): string {
    // Não deve haver um valor de fallback em produção por segurança.
    // Neste estágio, deve vir OBRIGATORIAMENTE do .env.
    return this.configService.get<string>('DB_PASSWORD', '');
  }

  get DB_DATABASE(): string {
    return this.configService.get<string>('DB_DATABASE', 'antibet_db');
  }

  // --- Propriedades de Autenticação ---

  get JWT_SECRET(): string {
    const secret = this.configService.get<string>('JWT_SECRET');
    if (!secret) {
      throw new Error('JWT_SECRET não está configurado no .env!');
    }
    return secret;
  }

  get JWT_EXPIRATION_TIME(): string {
    // Padrão de 1 hora.
    return this.configService.get<string>('JWT_EXPIRATION_TIME', '3600s');
  }
}