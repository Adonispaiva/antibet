import 'package:flutter/material.dart';
import 'package:antibet/src/core/services/app_config_service.dart';

// O Notifier gerencia o estado reativo das configurações do aplicativo, como o modo de tema.

class AppConfigNotifier extends ChangeNotifier {
  final AppConfigService _service;
  
  // Variável para armazenar o estado do modo escuro
  bool _isDarkMode = false;

  AppConfigNotifier(this._service);

  // Getter público para o estado (lido pelo AntiBetMobileApp no main.dart)
  bool get isDarkMode => _isDarkMode;

  /// Carrega o status do modo escuro a partir do serviço na inicialização.
  Future<void> loadConfig() async {
    _isDarkMode = await _service.loadDarkModeStatus();
    // Notifica os ouvintes (AppRouter e AntiBetMobileApp) sobre o estado inicial
    notifyListeners();
  }

  /// Alterna o modo escuro e persiste a mudança via serviço.
  Future<void> toggleDarkMode(bool newValue) async {
    if (_isDarkMode == newValue) return; // Evita trabalho desnecessário
    
    _isDarkMode = newValue;
    
    // 1. Persiste a mudança no serviço
    await _service.setDarkModeStatus(newValue);
    
    // 2. Notifica a UI
    notifyListeners();
    print('Modo Escuro alternado para: $_isDarkMode');
  }
}