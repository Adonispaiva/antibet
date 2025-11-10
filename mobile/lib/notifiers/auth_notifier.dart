import 'package:flutter/foundation.dart';

// Importações dos modelos, serviços e outros notifiers
import '../core/domain/user_model.dart'; 
import '../infra/services/auth_service.dart';
import 'behavioral_analytics_notifier.dart'; // Importa o Notifier de Análise

/// O AuthNotifier gerencia o estado de autenticação (logado/deslogado)
/// e o UserModel do usuário atual.
class AuthNotifier with ChangeNotifier {
  final AuthService _authService;
  BehavioralAnalyticsNotifier? _analyticsNotifier; // Dependência de Análise (Opcional)

  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = true; // Indica o carregamento do status inicial

  AuthNotifier(this._authService);

  // Getters Públicos
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  /// Método para injeção tardia (late-binding) do Notifier de Análise.
  /// Isto é usado no 'main.dart' para evitar um ciclo de dependência.
  void setAnalyticsNotifier(BehavioralAnalyticsNotifier analyticsNotifier) {
    _analyticsNotifier = analyticsNotifier;
  }

  /// Verifica o status de autenticação na inicialização do aplicativo
  Future<void> checkAuthenticationStatus() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final UserModel? user = await _authService.checkToken();
      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
        _currentUser = null;
      }
    } catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tenta autenticar o usuário com email e senha
  Future<void> login(String email, String password) async {
    try {
      final user = await _authService.login(email, password);
      _currentUser = user;
      _isAuthenticated = true;
      
      // RASTREAMENTO DE EVENTO (Missão Anti-Vício)
      // Dispara o evento de login para o Escore de Risco
      _analyticsNotifier?.trackEvent('login');
      
      notifyListeners();
    } catch (e) {
      // O erro é relançado para que a LoginView possa exibi-lo
      rethrow; 
    }
  }

  /// Executa o logout do usuário
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      // O logout não deve falhar para o usuário, mesmo se o serviço falhar
      if (kDebugMode) {
        print('Erro no serviço de logout (token): $e');
      }
    } finally {
      // RASTREAMENTO DE EVENTO (MissGoo Anti-Vício)
      _analyticsNotifier?.trackEvent('logout');

      // Limpa o estado local
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    }
  }
}