import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppConfigService } from './app-config.service';

/**
 * Módulo de Configuração Central da Aplicação.
 * Ele agrupa a lógica de carregamento do .env (ConfigModule)
 * e exporta o AppConfigService para acesso tipado às variáveis.
 */
@Module({
  imports: [
    // O ConfigModule é importado para carregar o .env
    ConfigModule.forRoot({
      isGlobal: false, // Desabilitamos o isGlobal aqui, pois este módulo será importado globalmente no AppModule
      envFilePath: '.env',
      expandVariables: true,
    }),
  ],
  providers: [
    // O AppConfigService é o serviço que fornece acesso tipado
    // às variáveis carregadas pelo ConfigModule
    AppConfigService
  ],
  exports: [
    // Exportar o AppConfigService o torna disponível
    // para injeção em qualquer módulo que importe este AppConfigurationModule.
    AppConfigService
  ]
})
export class AppConfigurationModule {}