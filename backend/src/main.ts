import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe, Logger } from '@nestjs/common';
import * as bodyParser from 'body-parser';

const logger = new Logger('Bootstrap');

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    // Para garantir que o rawBody seja lido para a validacao do Webhook do Stripe
    // O bodyParser.json() e usado aqui APENAS para endpoints que nao sao webhook.
    // O middleware de rawBody abaixo ira garantir que o body seja lido corretamente
    // como Buffer para o endpoint /payments/webhook.
    bufferLogs: true,
  });

  // 1. Global Pipes
  // Aplica o ValidationPipe globalmente para que todos os DTOs
  // sejam validados automaticamente.
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // Remove propriedades que nao estao no DTO
      transform: true, // Transforma payloads em instancias de DTO
    }),
  );

  // 2. CORS (Cross-Origin Resource Sharing)
  // Permite que o frontend (Flutter Web/Mobile) se conecte a API
  app.enableCors({
    origin: true, // Permitir todas as origens (ajustar em producao)
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    credentials: true,
  });

  // 3. Middlewares de Body Parser
  // Configura o Body Parser para garantir que o webhook leia o corpo RAW.
  // IMPORTANTE: O webhook (ex: /payments/webhook/stripe) DEVE ser processado como texto/Buffer,
  // enquanto as rotas normais sao processadas como JSON.
  app.use(
    (req, res, next) => {
      // Verifica se a rota é o webhook do Stripe
      if (req.originalUrl === '/payments/webhook/stripe') {
        // Usa o body-parser.raw para o webhook
        bodyParser.raw({ type: '*/*', limit: '5mb' })(req, res, next);
      } else {
        // Usa o body-parser.json para rotas normais
        bodyParser.json()(req, res, next);
      }
    }
  );


  // 4. Prefixos e Inicializacao
  app.setGlobalPrefix('api/v1'); // Padrao RESTful

  const port = process.env.PORT || 3000;
  await app.listen(port);
  logger.log(`API AntiBet rodando em: http://localhost:${port}/api/v1`);
}

bootstrap();