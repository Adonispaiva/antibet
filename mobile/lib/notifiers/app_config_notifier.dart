import 'package:antibet_mobile/infra/services/app_config_service.dart';
import 'package:antibet_mobile/infra/services/storage_service.dart';
import 'package:flutter/material.dart';

/// Chave de armazenamento para o tema escuro.
const String _kDarkModeKey = 'pref_dark_mode';

/// Gerencia o estado das configurações globais do aplicativo.
///
/// Utiliza o [StorageService] para persistir as preferências do usuário.
class AppConfigNotifier with ChangeNotifier {
  final AppConfigService _configService;
  final StorageService _storageService; // Nova dependência para persistência

  bool _isDarkModeEnabled = true; // Valor padrão: Dark Mode ativado

  // Construtor com injeção de dependência
  AppConfigNotifier(this._configService, this._storageService) {
    // Carrega a configuração no momento da criação da instância
    loadConfig();
  }

  // Getter público para o estado do Dark Mode
  bool get isDarkModeEnabled => _isDarkModeEnabled;

  /// Carrega as configurações persistidas do [StorageService].
  Future<void> loadConfig() async {
    try {
      final storedValue = await _storageService.read(_kDarkModeKey);
      
      // Se não houver valor salvo, usa o padrão (true).
      // Se houver, converte a string salva ('true' ou 'false') para bool.
      if (storedValue != null) {
        _isDarkModeEnabled = storedValue == 'true';
      } else {
        // Garantir que o valor padrão seja salvo na primeira execução
        _storageService.write(_kDarkModeKey, _isDarkModeEnabled.toString());
      }
    } catch (e) {
      debugPrint('[AppConfigNotifier] Erro ao carregar configurações: $e');
      // Em caso de falha de I/O, mantém o valor padrão.
    } finally {
      notifyListeners();
    }
  }

  /// Alterna o estado do Dark Mode e persiste a mudança.
  Future<void> toggleDarkMode(bool newValue) async {
    if (_isDarkModeEnabled != newValue) {
      _isDarkModeEnabled = newValue;
      notifyListeners();
      
      try {
        // Persiste a nova configuração
        await _storageService.write(_kDarkModeKey, newValue.toString());
      } catch (e) {
        debugPrint('[AppConfigNotifier] Erro ao salvar Dark Mode: $e');
        // Adicionar tratamento para reverter se o save falhar, se necessário
      }
    }
  }

  // Outras configurações (ex: notificações) virão aqui.
}