/*
 * NOTA DE DIREÇÃO:
 * v1.0 - Arquivo de Bootstrap Padrão do NestJS.
 * v1.1 - Adicionado 'rawBody: true' na inicialização.
 * Isso é CRÍTICO para que o Webhook do Stripe (que precisa do corpo
 * bruto da requisição) possa validar a assinatura.
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    // (v1.1) Habilita o 'raw body' na requisição (necessário para o Stripe Webhook)
    rawBody: true,
  });

  // Habilita o CORS
  app.enableCors({
    origin: '*', // TODO: Restringir para o 'CLIENT_URL' em produção
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
  });

  // Habilita a validação global de DTOs (class-validator)
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // Remove campos que não estão no DTO
      forbidNonWhitelisted: true, // Lança erro se campos extras forem enviados
      transform: true, // Transforma o payload nos tipos do DTO (ex: string -> number)
    }),
  );

  // Define o prefixo global da API (ex: /api/auth, /api/plans)
  app.setGlobalPrefix('api');

  const port = process.env.PORT || 3000;
  await app.listen(port);
  console.log(`[Orion] Backend AntiBet (v2.1) operacional na porta ${port}`);
}
bootstrap();