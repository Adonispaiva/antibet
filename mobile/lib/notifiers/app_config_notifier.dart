import 'package:flutter/material.dart';
import 'package:mobile/infra/services/app_config_service.dart';
import 'package:mobile/infra/services/app_config_service.dart' show AppConfigModel;

// O AppConfigNotifier gerencia o estado das configurações globais do aplicativo,
// como tema (dark mode) e idioma. Ele notifica o MaterialApp.router (main.dart)
// sobre mudanças no tema.
class AppConfigNotifier extends ChangeNotifier {
  final AppConfigService _configService;

  // Variável de Estado
  AppConfigModel _config = AppConfigModel(isDarkMode: false, languageCode: 'pt');
  bool _isLoading = false;

  // Construtor com injeção de dependência
  AppConfigNotifier(this._configService);

  // Getters para acessar o estado
  bool get isDarkMode => _config.isDarkMode;
  bool get isLoading => _isLoading;
  String get languageCode => _config.languageCode;

  // Define o estado de carregamento
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // 1. Carrega as configurações na inicialização (usado no main.dart)
  Future<void> loadConfig() async {
    _setLoading(true);
    try {
      _config = await _configService.loadConfig();
    } catch (e) {
      debugPrint('Erro ao carregar configurações: $e. Usando padrões.');
      // Em caso de falha, mantém a configuração padrão
    } finally {
      _setLoading(false);
    }
  }

  // 2. Permite que o usuário mude o modo escuro
  Future<void> toggleDarkMode({required bool enable}) async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      // Cria uma nova instância do modelo com a mudança de estado
      final newConfig = AppConfigModel(
        isDarkMode: enable,
        languageCode: _config.languageCode,
      );

      final success = await _configService.saveConfig(newConfig);

      if (success) {
        _config = newConfig;
        // Notifica o MaterialApp.router (main.dart) para mudar o tema
      } else {
        debugPrint('Falha ao salvar a configuração no serviço.');
      }
    } catch (e) {
      debugPrint('Erro ao salvar ou mudar tema: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // 3. Atualiza o código do idioma (lógica similar a toggleDarkMode)
  Future<void> updateLanguage(String newCode) async {
    if (_isLoading) return;
    
    _setLoading(true);
    
    try {
      final newConfig = AppConfigModel(
        isDarkMode: _config.isDarkMode,
        languageCode: newCode,
      );
      final success = await _configService.saveConfig(newConfig);
      
      if (success) {
        _config = newConfig;
      }
    } catch (e) {
      debugPrint('Erro ao atualizar idioma: $e');
    } finally {
      _setLoading(false);
    }
  }
}