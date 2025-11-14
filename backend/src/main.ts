// backend/src/main.ts

/*
 * NOTA DE DIREÇÃO (Orion v1.2):
 * Arquivo final de Bootstrap.
 * v1.1 (Adonis): Adicionado 'rawBody: true' (Crítico para Stripe).
 * v1.2 (Orion): Fundido v1.1 com ConfigService e GlobalPrefix.
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config'; // Importa o ConfigService

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    // (v1.1) Habilita o 'raw body' na requisição (necessário para o Stripe Webhook)
    rawBody: true,
  });

  // 1. Acessa o ConfigService
  const configService = app.get(ConfigService);
  
  // 2. Define a porta da API (padrão 3000 se não estiver no .env)
  const port = configService.get<number>('API_PORT') || 3000;

  // 3. Habilita o CORS
  app.enableCors({
    origin: '*', // TODO: Restringir para o 'CLIENT_URL' em produção
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
  });

  // 4. Habilita a validação global de DTOs (class-validator)
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // Remove campos que não estão no DTO
      forbidNonWhitelisted: true, // Lança erro se campos extras forem enviados
      transform: true, // Transforma o payload nos tipos do DTO
    }),
  );

  // 5. Define o prefixo global da API (ex: /api/auth, /api/journal)
  app.setGlobalPrefix('api');

  console.log(`[Orion] Servidor Backend AntiBet (v1.2) iniciando na porta ${port}...`);
  await app.listen(port);
}
bootstrap();