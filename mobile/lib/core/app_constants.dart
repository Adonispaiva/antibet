// lib/core/app_constants.dart
// Este arquivo armazena constantes globais de configuração e domínio.

class AppConstants {
  // 1. Strings e Nomes de Aplicativo
  static const String appName = 'AntiBet Mobile';
  static const String appVersion = '1.0.0';

  // 2. Configurações de Rede/API
  // URL base para comunicação com o Backend.
  // IMPORTANTE: Deve ser atualizada com o endereço ngrok ou IP local/cloud real.
  // Assumindo a porta padrão de desenvolvimento local.
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1'; 
  
  // Timeout para requisições HTTP em milissegundos
  static const int apiTimeout = 15000; 

  // 3. Chaves e Tokens (para SharedPreferences, etc.)
  static const String tokenKey = 'AUTH_TOKEN_KEY';
  static const String userIdKey = 'USER_ID_KEY';

  // 4. Configurações de UI
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;

  // Construtor privado para evitar instanciação, pois a classe contém apenas estáticos.
  AppConstants._();
}