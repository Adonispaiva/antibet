import 'package:flutter/material.dart';
import 'package:antibet/src/core/services/auth_service.dart';
import 'package:antibet/src/core/notifiers/behavioral_analytics_notifier.dart'; // Dependência para late-binding

// O Notifier gerencia o estado reativo de autenticação para a UI (AppRouter, Splash, etc.).

class AuthNotifier extends ChangeNotifier {
  final AuthService _service;
  
  // Variável para armazenar o estado de login
  bool _isLoggedIn = false;
  
  // Late-Binding para Notifiers que precisam reagir a eventos de Auth.
  BehavioralAnalyticsNotifier? _analyticsNotifier;

  AuthNotifier(this._service);

  // Getter público para o estado
  bool get isLoggedIn => _isLoggedIn;

  // Setter para injeção de dependência cruzada (Late-Binding)
  void setAnalyticsNotifier(BehavioralAnalyticsNotifier notifier) {
    _analyticsNotifier = notifier;
  }

  /// Verifica o status de autenticação na inicialização do aplicativo.
  Future<void> checkAuthenticationStatus() async {
    _isLoggedIn = await _service.checkAuthenticationStatus();
    // Notifica os ouvintes (principalmente o AppRouter) sobre o estado inicial
    notifyListeners();
  }

  /// Tenta realizar o login e atualiza o estado.
  Future<bool> login(String email, String password) async {
    final success = await _service.login(email, password);
    
    if (success) {
      _isLoggedIn = true;
      // Notifica o Analytics sobre o evento de Login (simulando um evento comportamental)
      _analyticsNotifier?.recordBehavioralEvent('login_successful');
      notifyListeners();
    }
    return success;
  }

  /// Realiza o logout e atualiza o estado.
  Future<void> logout() async {
    await _service.logout();
    _isLoggedIn = false;
    // Notifica o Analytics sobre o evento de Logout (pode ser usado para calibração)
    _analyticsNotifier?.recordBehavioralEvent('logout');
    notifyListeners();
  }
}