import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antibet/features/auth/services/auth_service.dart';

class AuthInterceptor extends Interceptor {
  final Ref _ref;

  AuthInterceptor({required Ref ref}) : _ref = ref;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Acessa o AuthService via Riverpod Ref
    final authService = _ref.read(authServiceProvider);
    
    // 1. Tenta obter o token armazenado localmente
    final token = await authService.getToken();

    if (token != null && token.isNotEmpty) {
      // 2. Se o token existir, injeta-o no cabeçalho da requisição
      options.headers['Authorization'] = 'Bearer $token';
    }

    // 3. Continua a requisição
    handler.next(options);
  }

  // Não precisamos de lógica complexa nos métodos onResponse ou onError, 
  // pois o ErrorInterceptor fará o tratamento de 401/403.
}