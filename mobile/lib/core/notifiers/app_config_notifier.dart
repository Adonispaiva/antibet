import 'package:flutter/foundation.dart';

/// Notifier responsável por gerenciar o estado das configurações globais do aplicativo,
/// como tema (claro/escuro) e preferências de notificação.
class AppConfigNotifier extends ChangeNotifier {
  // Estado privado do tema. Padrão: Claro.
  bool _isDarkMode = false;
  
  // Estado privado do status das notificações. Padrão: Habilitado.
  bool _areNotificationsEnabled = true;

  // Getters públicos
  bool get isDarkMode => _isDarkMode;
  bool get areNotificationsEnabled => _areNotificationsEnabled;

  /// Alterna o tema de claro para escuro ou vice-versa.
  Future<void> toggleTheme() async {
    // Simulação de delay para operação de persistência (StorageService).
    await Future.delayed(const Duration(milliseconds: 200));
    
    _isDarkMode = !_isDarkMode;
    
    // Notifica a UI para recarregar com o novo tema.
    notifyListeners();
  }

  /// Define explicitamente o tema.
  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode != value) {
      await Future.delayed(const Duration(milliseconds: 200));
      _isDarkMode = value;
      notifyListeners();
    }
  }

  /// Alterna o status de ativação das notificações.
  Future<void> toggleNotifications(bool value) async {
    if (_areNotificationsEnabled != value) {
      await Future.delayed(const Duration(milliseconds: 200));
      _areNotificationsEnabled = value;
      notifyListeners();
    }
  }
}