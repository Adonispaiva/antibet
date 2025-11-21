// mobile/lib/core/config/app_config.dart

/// Classe central para armazenar URLs e constantes de configuracao
/// da API do Backend.
class AppConfig {
  // ATENÇÃO: Em produção, estas URLs serao lidas de forma assíncrona
  // ou de um arquivo de build/ambiente (ex: .env)
  
  static const String _baseUrlDev = 'http://10.0.2.2:3000/api/v1'; // Android Emulator
  static const String _baseUrlProd = 'https://api.antibet.com/api/v1'; 

  /// Retorna a URL base da API (ajustavel conforme o ambiente)
  static String get baseUrl {
    // Para simplificar o desenvolvimento local, usaremos a URL de desenvolvimento.
    // O Endereço 10.0.2.2 e o alias padrao do Android Emulator para o localhost da maquina host.
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    
    return isProduction ? _baseUrlProd : _baseUrlDev;
  }
  
  // Constantes de Seguranca
  static const int apiTimeoutSeconds = 15;
}