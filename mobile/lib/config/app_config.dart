// mobile/lib/config/app_config.dart

/// Classe de configuração centralizada para variáveis globais e de ambiente.
class AppConfig {
  // A URL base para a API do Backend NestJS.
  // Está hardcoded aqui temporariamente. Em uma arquitetura de produção real,
  // isso seria injetado via Flutter Flavor ou flutter_dotenv.
  static const String apiUrl = 'http://localhost:3000/api';
  
  // URL de teste (para simulação ou ambiente de QA)
  static const String testUrl = 'http://test.api.antibet.com/api';

  // URLs de Callback de Pagamento (usadas pelo PaymentsApiService)
  static const String paymentSuccessUrl = 'antibet://payment/success';
  static const String paymentCancelUrl = 'antibet://payment/cancel';
}