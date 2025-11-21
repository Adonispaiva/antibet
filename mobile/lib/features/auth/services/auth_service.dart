import 'package:dio/dio.dart';
import 'package:antibet/core/network/dio_provider.dart'; // Importação do CustomDio
import 'package:antibet/features/auth/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Para simular armazenamento seguro do token

class AuthService {
  final Dio _dio;
  
  // Chave para armazenamento seguro do token localmente
  static const String _tokenKey = 'auth_token';

  AuthService({Dio? dio}) : _dio = dio ?? CustomDio.instance;

  // Endpoint de autenticação
  static const String _loginPath = '/auth/login';
  static const String _logoutPath = '/auth/logout';
  
  /// ----------------------------------------------------
  /// LOGIN: Autentica o usuário e armazena o token
  /// ----------------------------------------------------
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _dio.post(_loginPath, data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 && response.data != null) {
        // Assume que a resposta da API retorna o JSON do UserModel com o token
        final user = UserModel.fromJson(response.data);
        
        // Armazenamento do token para uso futuro pelo Interceptor
        await _saveToken(user.token);

        return user;
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Resposta da API inválida',
      );
    } catch (e) {
      // Re-lança para o Provider tratar
      rethrow; 
    }
  }

  /// ----------------------------------------------------
  /// LOGOUT: Encerra a sessão (local e opcionalmente na API)
  /// ----------------------------------------------------
  Future<void> logout() async {
    try {
      // Opcional: Notifica o backend sobre o logout
      await _dio.post(_logoutPath); 
    } catch (e) {
      // Ignora erro de logout no backend, focando na remoção local.
      // Em casos reais, o Interceptor lida com 401/403 forçando o logout local
    } finally {
      // Limpa o token do armazenamento seguro
      await _deleteToken();
    }
  }

  /// ----------------------------------------------------
  /// HELPERS DE TOKENS (Simulação de Secure Storage)
  /// ----------------------------------------------------

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}