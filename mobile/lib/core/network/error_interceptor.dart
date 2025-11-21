import 'package:antibet/features/auth/providers/user_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [ErrorInterceptor] é responsável pelo tratamento global de erros HTTP.
///
/// Sua principal função é detectar falhas de autenticação (401/403)
/// e forçar o logout do usuário, padronizando a experiência de erro.
class ErrorInterceptor extends Interceptor {
  final Ref ref;

  ErrorInterceptor(this.ref);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;

    // 1. Tratamento de Erros de Autenticação (401/403)
    if (statusCode == 401 || statusCode == 403) {
      // Se o token for inválido, expirado ou não autorizado,
      // forçamos o logout do usuário.
      print('HTTP $statusCode: Token Inválido. Forçando Logout...');

      // Chamamos o logout do UserProvider.notifier
      // Usamos ref.read para disparar a ação.
      await ref.read(userProvider.notifier).logout();

      // Devolvemos o erro para a aplicação para que a chamada falhe,
      // mas garantimos que o estado do usuário (no Riverpod) foi limpo.
      // O 'handler.reject' faz com que a requisição retorne um erro.
      return handler.reject(err);
    }

    // 2. Tratamento de Outros Erros
    // Para outros erros (ex: 500, timeout), logamos a falha
    // e passamos o erro adiante para ser tratado pelo service layer.
    print('HTTP Error ${statusCode ?? "N/A"}: ${err.message}');

    handler.next(err);
  }
}