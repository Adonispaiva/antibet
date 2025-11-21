import 'package:antibet/features/auth/providers/user_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [AuthInterceptor] é um interceptor do Dio que adiciona o token JWT
/// de autenticação a todas as requisições de saída, se o usuário estiver logado.
///
/// Isso centraliza a lógica de autenticação em um único local,
/// seguindo o princípio da Arquitetura Limpa.
class AuthInterceptor extends Interceptor {
  // A ref é necessária para acessar o estado do Riverpod
  final Ref ref;

  AuthInterceptor(this.ref);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // 1. Acessa o estado atual do UserProvider
    final userState = ref.read(userProvider);

    // 2. Verifica se o usuário está no estado 'UserLoaded'
    final token = userState.whenOrNull(
      loaded: (user) => user.token,
    );

    if (token != null) {
      // 3. Injeta o token no cabeçalho da requisição
      options.headers['Authorization'] = 'Bearer $token';
    }

    // 4. Continua a requisição
    handler.next(options);
  }

  // Não precisamos de lógica customizada para onResponse ou onError neste arquivo.
}