import 'package:antibet_mobile/infra/services/auth_service.dart';
import 'package:antibet_mobile/models/user_model.dart';
import 'package:flutter/material.dart';

/// Enum para representar os possíveis estados de autenticação.
enum AuthStatus {
  uninitialized, // Estado inicial, checando
  loading,       // Carregando (ex: durante login)
  authenticated, // Autenticado
  unauthenticated  // Não autenticado
}

/// Gerencia o estado de autenticação do usuário.
///
/// Utiliza o [AuthService] para realizar operações e notifica a UI
/// sobre mudanças no estado (logado, deslogado, carregando) e
/// armazena os dados do [UserModel].
class AuthNotifier with ChangeNotifier {
  final AuthService _authService;

  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _user;
  String? _errorMessage;

  // Construtor com injeção de dependência.
  AuthNotifier(this._authService) {
    // Ao iniciar, verifica o status da autenticação
    checkAuthStatus();
  }

  // Getters públicos (read-only)
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Tenta realizar o login do usuário.
  Future<bool> login(String email, String password) async {
    _setStatus(AuthStatus.loading);
    _errorMessage = null;

    try {
      // Chama o serviço (que agora retorna UserModel)
      final user = await _authService.login(email, password);
      _user = user;
      _setStatus(AuthStatus.authenticated);
      return true;
    } catch (e) {
      debugPrint('[AuthNotifier] Erro no login: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }

  /// Tenta registrar um novo usuário.
  Future<bool> register(String name, String email, String password) async {
    _setStatus(AuthStatus.loading);
    _errorMessage = null;

    try {
      // Chama o serviço de registro
      final user = await _authService.register(name, email, password);
      _user = user;
      _setStatus(AuthStatus.authenticated); // Loga o usuário automaticamente
      return true;
    } catch (e) {
      debugPrint('[AuthNotifier] Erro no registro: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }

  /// Verifica o status de autenticação (ex: no boot do app).
  Future<void> checkAuthStatus() async {
    _setStatus(AuthStatus.loading); // Visualmente, pode ser um "uninitialized"

    try {
      // Chama o serviço (retorna UserModel? ou null)
      final user = await _authService.checkAuthStatus();
      if (user != null) {
        _user = user;
        _setStatus(AuthStatus.authenticated);
      } else {
        _user = null;
        _setStatus(AuthStatus.unauthenticated);
      }
    } catch (e) {
      debugPrint('[AuthNotifier] Erro ao checar status: $e');
      _user = null;
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  /// Realiza o logout do usuário.
  Future<void> logout() async {
    _setStatus(AuthStatus.loading);
    try {
      await _authService.logout();
      _user = null;
      _setStatus(AuthStatus.unauthenticated);
    } catch (e) {
      debugPrint('[AuthNotifier] Erro no logout: $e');
      // Mesmo em erro, força o estado de deslogado na UI
      _user = null;
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  /// Helper interno para gerenciar o estado e notificar ouvintes.
  void _setStatus(AuthStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      notifyListeners();
    }
  }
}