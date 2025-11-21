import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:antibet/features/user/models/user_model.dart';
import 'package:antibet/features/auth/services/auth_service.dart';
import 'package:antibet/features/user/services/user_service.dart';

/// Provider (Gerenciador de Estado) para o Usuário e Autenticação.
/// 
/// Gerencia o estado do usuário logado, o status de login/logout e
/// a inicialização do perfil na abertura do app.
@LazySingleton()
class UserProvider with ChangeNotifier {
  final IAuthService _authService;
  final IUserService _userService;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Propriedade crucial para o roteador verificar se o usuário está autenticado.
  bool get isLoggedIn => _currentUser != null; 

  UserProvider(this._authService, this._userService);

  /// Tenta validar o token existente e carregar o perfil do usuário na inicialização.
  Future<void> initializeUser() async {
    _setLoading(true);
    try {
      // 1. Verifica se há um token válido persistido localmente
      final tokenIsValid = await _authService.checkTokenValidity(); 
      if (tokenIsValid) {
        // 2. Se o token for válido, busca o perfil completo do usuário
        _currentUser = await _userService.fetchCurrentUser();
      } else {
        _currentUser = null;
      }
      _errorMessage = null;
    } catch (e) {
      // Em caso de erro na rede ou token expirado/inválido, desloga localmente
      _currentUser = null;
      _errorMessage = 'Falha na inicialização da sessão: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  /// Executa a operação de Login.
  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      // O authService lida com a API e o armazenamento do token.
      final authResponse = await _authService.login(email, password);
      
      // Assumimos que a resposta contém o modelo completo do usuário para definir o estado
      _currentUser = authResponse.user; 
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Falha no login: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Executa a operação de Logout.
  Future<void> logout() async {
    _setLoading(true);
    await _authService.logout(); // Remove o token localmente
    _currentUser = null;
    _errorMessage = null;
    _setLoading(false);
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}