import 'package:flutter/material.dart';
import 'package:antibet/services/auth/auth_service.dart'; // Importa o Service
import 'package:antibet/models/user_model.dart'; // Importa o modelo de usuário da localização correta

/// Gerenciador de Estado de Autenticação (AuthNotifier)
class AuthNotifier extends ChangeNotifier {
  final AuthService _authService; // Injeção de Dependência

  // Estado de autenticação.
  bool _isAuthenticated = false;
  // Dados do usuário autenticado.
  UserModel? _currentUser;
  // Estado de carregamento inicial (verificando sessão, token, etc.).
  bool _isLoading = true; 

  bool get isAuthenticated => _isAuthenticated;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  // Construtor com injeção de dependência do AuthService
  AuthNotifier(this._authService) {
    _checkInitialSession();
  }

  /// Verifica se há uma sessão persistida e realiza o login automático.
  void _checkInitialSession() async {
    try {
      final user = await _authService.checkToken();
      if (user != null) {
        _isAuthenticated = true;
        _currentUser = user;
      }
    } catch (e) {
      // Falha na verificação do token (rede, expirado, etc.)
      print('Erro ao verificar sessão inicial: $e');
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Processa o Login chamando o AuthService.
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.login(email, password);
      
      _isAuthenticated = true;
      _currentUser = user;
      
    } on AuthException catch (e) {
      // Erro de credenciais inválidas ou API
      print('Erro de login (AuthException): ${e.message}');
      _isAuthenticated = false;
      // TODO: Usar um Notifier de UI (ex: SnackBarNotifier) para mostrar 'e.message'
    } catch (e) {
      // Outros erros
      print('Erro de login desconhecido: $e');
      _isAuthenticated = false;
      // TODO: Mostrar erro genérico
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Processa o Logout chamando o AuthService.
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    await _authService.logout();
    
    _isAuthenticated = false;
    _currentUser = null;
    _isLoading = false;
    
    notifyListeners();
  }
}