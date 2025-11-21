import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antibet/core/network/dio_provider.dart';

/// Serviço responsável pela comunicação com os endpoints de Autenticação.
class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  /// Realiza o login do usuário.
  /// Retorna o token JWT em caso de sucesso.
  Future<String> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      // Assumindo que a API retorna o token no campo 'token' ou 'access_token'
      return response.data['token'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Registra um novo usuário.
  Future<void> register(String email, String password) async {
    try {
      await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Invalida o token JWT no servidor (logout).
  /// Esta chamada não precisa de um retorno, pois o AuthInterceptor trata o 401/403
  /// e o AuthNotifier lida com a limpeza local.
  Future<void> logout() async {
    try {
      // Endpoint para invalidar a sessão ou token no backend
      await _dio.post('/auth/logout');
    } on DioException {
      // Ignoramos erros de 401/403 aqui, pois o token pode já ter expirado localmente,
      // e a limpeza de estado local é o principal objetivo.
    }
  }

  /// Helper para tratamento de erros de resposta
  Exception _handleError(DioException e) {
    if (e.response != null) {
      // Tenta extrair mensagem de erro da API
      final message = e.response?.data['message'] ?? 'Erro desconhecido na autenticação.';
      return Exception(message);
    }
    return Exception('Erro de conexão com o servidor.');
  }
}

/// Provider global para acessar o AuthService.
final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.read(dioProvider);
  return AuthService(dio);
});