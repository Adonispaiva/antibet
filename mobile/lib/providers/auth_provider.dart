import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:inovexa_antibet/models/user.model.dart';
import 'package:inovexa_antibet/services/api_service.dart';
import 'package:inovexa_antibet/services/storage_service.dart'; // (Novo)

// Enum para os estados de autenticação
enum AuthStatus {
  uninitialized, // (Estado inicial enquanto verifica o storage)
  authenticated,
  unauthenticated,
  loading, // (Usado para login/register manual)
}

class AuthProvider with ChangeNotifier {
  AuthStatus _status = AuthStatus.uninitialized; // (Alterado)
  String? _token;
  String? _authError;
  User? _currentUser; 

  // Getters
  AuthStatus get status => _status;
  String? get token => _token;
  String? get authError => _authError;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    // (Novo) Tenta logar automaticamente ao iniciar o app
    _tryAutoLogin();
  }

  /// (Novo) Tenta ler o token do storage e autenticar o usuário.
  Future<void> _tryAutoLogin() async {
    final storedToken = await storageService.readToken();

    if (storedToken == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    // Se encontrou um token, configura-o e tenta buscar o perfil
    _token = storedToken;
    apiService.setAuthToken(_token!);
    
    // (Reutiliza a lógica da v1.1)
    await fetchUserProfile(); 

    // Se fetchUserProfile falhar (ex: token expirado), ele
    // internamente chamará logout() e mudará o status para unauthenticated.
    // Se for bem-sucedido, o status será authenticated.
  }

  /// Tenta registrar um novo usuário.
  Future<bool> register(Map<String, dynamic> userData) async {
    _status = AuthStatus.loading;
    _authError = null;
    notifyListeners();

    try {
      final response = await apiService.dio.post(
        '/auth/register',
        data: userData,
      );

      if (response.statusCode == 201 && response.data['access_token'] != null) {
        _token = response.data['access_token'];
        apiService.setAuthToken(_token!);

        // (Novo) Salva o token no storage seguro
        await storageService.saveToken(_token!);

        await fetchUserProfile(); // (v1.1)
        return true;
      } else {
        throw Exception('Falha ao registrar: Resposta inesperada.');
      }
    } on DioException catch (e) {
      _handleAuthError(e, 'Registrar');
      return false;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _authError = 'Erro desconhecido ao registrar: $e';
      notifyListeners();
      return false;
    }
  }

  /// Tenta logar um usuário existente.
  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _authError = null;
    notifyListeners();

    try {
      final response = await apiService.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['access_token'] != null) {
        _token = response.data['access_token'];
        apiService.setAuthToken(_token!);

        // (Novo) Salva o token no storage seguro
        await storageService.saveToken(_token!);

        await fetchUserProfile(); // (v1.1)
        return true;
      } else {
        throw Exception('Falha ao logar: Resposta inesperada.');
      }
    } on DioException catch (e) {
      _handleAuthError(e, 'Logar');
      return false;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _authError = 'Erro desconhecido ao logar: $e';
      notifyListeners();
      return false;
    }
  }

  /// (v1.1) Busca os dados do usuário autenticado (endpoint /auth/profile)
  Future<void> fetchUserProfile() async {
    if (_token == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      final response = await apiService.dio.get('/auth/profile');

      if (response.statusCode == 200) {
        _currentUser = User.fromJson(response.data);
        _status = AuthStatus.authenticated; 
      } else {
        throw Exception('Falha ao buscar perfil do usuário.');
      }
    } catch (e) {
      // (Alterado) Se falhar, chama o logout para limpar o token inválido
      _handleAuthError(e as DioException, 'buscar perfil');
      await logout(); // Força o logout se o perfil falhar
    } finally {
      notifyListeners();
    }
  }

  /// Realiza o logout do usuário.
  Future<void> logout() async {
    _token = null;
    _currentUser = null; 
    apiService.clearAuthToken();
    
    // (Novo) Limpa o token do storage seguro
    await storageService.deleteToken();

    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Manipulador de erros centralizado para DioExceptions.
  void _handleAuthError(DioException e, String action) {
    // (Alterado) Não muda o status aqui, deixa o 'logout' ou 'login' tratar
    // _status = AuthStatus.unauthenticated; 
    
    if (e.response != null && e.response?.data['message'] != null) {
      _authError = 'Falha ao $action: ${e.response?.data['message']}';
    } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      _authError = 'Falha de conexão. Verifique sua rede.';
    } else {
      _authError = 'Falha ao $action. Tente novamente.';
    }
    
    // (Alterado) Garante que o status seja 'unauthenticated' se o erro
    // não foi durante o loading (ex: falha no auto-login)
    if (_status != AuthStatus.loading) {
       _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }
}