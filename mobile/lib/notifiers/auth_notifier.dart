import 'package:flutter/foundation.dart';
import 'package:mobile/infra/services/auth_service.dart';
// Importação de Notifier dependente, se necessário (ex: Analytics)
import 'package:mobile/notifiers/behavioral_analytics_notifier.dart';

// Este é o Notifier central para gerenciar todo o estado de autenticação
// e notificar os Widgets (LoginScreen, RegisterScreen, AppRouter, etc.) sobre mudanças.
class AuthNotifier extends ChangeNotifier {
  // O Service de autenticação é injetado no construtor (Dependency Injection)
  final AuthService _authService;
  
  // Notifier para injeção de dependência cruzada (Late-Binding)
  BehavioralAnalyticsNotifier? _analyticsNotifier;

  // Variáveis de Estado
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  AuthNotifier(this._authService);

  // Getters para acessar o estado
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Setter para injeção de dependência cruzada (usado no main.dart)
  void setAnalyticsNotifier(BehavioralAnalyticsNotifier notifier) {
    _analyticsNotifier = notifier;
  }

  // Define o estado de carregamento e notifica os ouvintes
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Define a mensagem de erro e notifica os ouvintes
  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  // Limpa a mensagem de erro
  void clearErrorMessage() {
    _setErrorMessage(null);
  }

  // 1. Checa o status de autenticação (usado na inicialização do main.dart)
  Future<void> checkAuthenticationStatus() async {
    _setLoading(true);
    try {
      final token = await _authService.getToken();
      _isAuthenticated = token != null;
      if (_isAuthenticated) {
        // Se autenticado, pode ser um bom lugar para carregar dados do usuário
        // ou acionar eventos de Analytics
        _analyticsNotifier?.logEvent('User_Session_Restored');
      }
    } catch (e) {
      _isAuthenticated = false;
      _setErrorMessage('Erro ao verificar sessão: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 2. Lógica de Login
  Future<void> login({required String email, required String password}) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final user = await _authService.login(email: email, password: password);
      
      if (user != null) {
        _isAuthenticated = true;
        // Aciona evento de Analytics
        _analyticsNotifier?.logEvent('User_Logged_In', parameters: {'email': email});
      } else {
        // Tratamento de falha de login (ex: credenciais inválidas)
        _setErrorMessage('Credenciais inválidas. Por favor, tente novamente.');
        _isAuthenticated = false;
      }
    } catch (e) {
      _setErrorMessage('Erro de conexão ao tentar fazer login. Tente novamente.');
      _isAuthenticated = false;
    } finally {
      // Notifica Widgets (como AppRouter) para reagir à mudança de _isAuthenticated
      _setLoading(false);
    }
  }

  // 3. Lógica de Cadastro (Registro)
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
      );

      if (user != null) {
        // Assumimos que o registro bem-sucedido também autentica o usuário
        _isAuthenticated = true;
        _analyticsNotifier?.logEvent('User_Registered');
      } else {
        // Tratamento de falha de registro (ex: e-mail já em uso)
        _setErrorMessage('Falha no cadastro. O e-mail pode já estar em uso.');
        _isAuthenticated = false;
      }
    } catch (e) {
      _setErrorMessage('Erro de conexão ao tentar se cadastrar. Tente novamente.');
      _isAuthenticated = false;
    } finally {
      _setLoading(false);
    }
  }

  // 4. Lógica de Logout
  Future<void> logout() async {
    _setLoading(true);
    await _authService.logout();
    _isAuthenticated = false;
    _setErrorMessage(null);
    // Aciona evento de Analytics
    _analyticsNotifier?.logEvent('User_Logged_Out');
    // Notifica Widgets e o AppRouter
    _setLoading(false);
  }
}