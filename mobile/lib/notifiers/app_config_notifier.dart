import 'package:flutter/foundation.dart';

// Importações dos modelos e serviços
import '../core/domain/app_config_model.dart'; 
import '../infra/services/app_config_service.dart';

/// O Notifier de Configurações gerencia o estado global das preferências do aplicativo.
/// Ele interage com o AppConfigService para persistência local.
class AppConfigNotifier with ChangeNotifier {
  final AppConfigService _configService;

  AppConfigModel _config = kDefaultAppConfig;
  bool _isLoading = true;

  AppConfigNotifier(this._configService);

  // Getters Públicos
  AppConfigModel get config => _config;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _config.isDarkMode;
  bool get areNotificationsEnabled => _config.areNotificationsEnabled;
  String get languageCode => _config.languageCode;

  /// Carrega as configurações salvas na inicialização do aplicativo.
  Future<void> loadConfig() async {
    _isLoading = true;
    notifyListeners();
    try {
      _config = await _configService.loadConfig();
    } catch (e) {
      if (kDebugMode) {
        print('Falha ao carregar configurações salvas: $e');
      }
      // Em caso de falha, mantém a configuração padrão (kDefaultAppConfig)
      _config = kDefaultAppConfig;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Atualiza uma ou mais configurações e as persiste localmente.
  Future<void> updateConfig({
    bool? isDarkMode,
    bool? areNotificationsEnabled,
    String? languageCode,
  }) async {
    // Cria uma nova instância imutável com os dados atualizados
    final updatedConfig = _config.copyWith(
      isDarkMode: isDarkMode,
      areNotificationsEnabled: areNotificationsEnabled,
      languageCode: languageCode,
    );
    
    // Se a configuração não mudou, evita I/O desnecessário
    if (updatedConfig == _config) {
      return;
    }

    // Atualiza o estado local imediatamente para feedback instantâneo da UI
    _config = updatedConfig;
    notifyListeners(); 

    // Persiste a nova configuração no serviço
    try {
      await _configService.saveConfig(_config);
    } catch (e) {
      if (kDebugMode) {
        print('Falha ao persistir configurações: $e');
      }
      // O erro de salvamento é silencioso, mas é logado.
    }
  }
}