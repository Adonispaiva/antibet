// mobile/lib/features/auth/notifiers/auth_notifier.dart

import 'package:antibet/core/services/auth_service.dart';
import 'package:antibet/core/services/user_service.dart';
import 'package:antibet/features/user/models/user_model.dart'; // Assumindo a existência de UserModel
import 'package:flutter/foundation.dart';

/// Notifier responsável por gerenciar o estado global de autenticação e o perfil do usuário.
class AuthNotifier extends ChangeNotifier {
  final AuthService _authService;
  final UserService _userService; // Usado para obter os dados do perfil
  
  // Estado
  bool _isAuthenticated = false;
  bool _isLoading = true;
  UserModel? _user;

  AuthNotifier(this._authService, this._userService) {
    // Inicia a verificação de auto-login na criação do Notifier
    checkAuthStatus();
  }

  // Getters para a UI
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  UserModel? get user => _user;

  /// Verifica o status do token persistido para auto-login.
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    final token = await _authService.getToken();

    if (token != null && token.isNotEmpty) {
      // 1. Token encontrado: tenta carregar os dados do perfil
      final success = await _fetchUserProfile();
      _isAuthenticated = success;
    } else {
      // 2. Token não encontrado: Não autenticado
      _isAuthenticated = false;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  /// Tenta realizar o login.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Chama a API de login e obtém o token
      final success = await _authService.attemptLogin(email, password);
      
      if (success) {
        // 2. Login bem-sucedido: Carrega perfil
        final profileSuccess = await _fetchUserProfile(); 
        _isAuthenticated = profileSuccess;
      } else {
        // 3. Falha de Login
        _isAuthenticated = false;
      }
      return success;
    } catch (e) {
      debugPrint('AuthNotifier Login Error: $e');
      _isAuthenticated = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Tenta realizar o registro de um novo usuário.
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    try {
        // 1. Chama a API de registro (simulada no AuthService)
        final success = await _authService.attemptRegistration(name, email, password);
        
        if (success) {
            // 2. Registro bem-sucedido: Carrega perfil (o login é implícito no backend)
            final profileSuccess = await _fetchUserProfile();
            _isAuthenticated = profileSuccess;
        } else {
            // 3. Falha de Registro
            _isAuthenticated = false;
        }
        return success;
    } catch (e) {
        debugPrint('AuthNotifier Register Error: $e');
        _isAuthenticated = false;
        return false;
    } finally {
        _isLoading = false;
        notifyListeners();
    }
  }

  /// Realiza o logout, limpando o token e o estado do usuário.
  Future<void> logout() async {
    await _authService.clearToken();
    // Opcional: Limpar dados de outros serviços (ex: MetricsService, JournalService)
    
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }

  /// Busca os dados do perfil do usuário logado via UserService (API).
  /// Retorna true se o perfil foi carregado, false se falhou.
  Future<bool> _fetchUserProfile() async {
    try {
      // O UserService deve saber como usar o token persistido pelo AuthService.
      _user = await _userService.fetchUserProfile();
      return _user != null;
    } catch (e) {
      debugPrint('AuthNotifier Error fetching profile: $e');
      _user = null;
      // Se a API falhar ao carregar o perfil (token inválido/expirado), faz logout forçado.
      await _authService.clearToken(); 
      _isAuthenticated = false;
      return false;
    }
  }
  
  /// Atualiza o perfil do usuário localmente (usado após um PATCH na tela de perfil).
  void updateLocalProfile(UserModel updatedUser) {
      _user = updatedUser;
      notifyListeners();
  }
}