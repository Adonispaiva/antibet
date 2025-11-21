/// [AppConstants] armazena todas as constantes globais
/// e URLs base para o aplicativo.
abstract class AppConstants {
  // --- Configuração da API ---
  
  // URL base para todas as chamadas à API.
  // Em um ambiente de produção real, isso seria definido
  // por variáveis de ambiente ou flavors.
  static const String apiBaseUrl = 'https://api.inovexa.com.br/antibet/v1';

  // --- Chaves de Storage Seguras ---
  
  // Chave usada para armazenar e recuperar o objeto do usuário (token).
  static const String userStorageKey = 'user';

  // --- Configurações de UI ---

  // Duração padrão para a exibição de SnackBar (mensagens de erro).
  static const Duration snackBarDuration = Duration(seconds: 3);

  // --- Configurações de Tempo ---

  // Timeout padrão para chamadas de rede (em segundos).
  static const int networkTimeoutSeconds = 15;
}