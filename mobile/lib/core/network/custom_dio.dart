import 'package:antibet/core/config/app_constants.dart';
import 'package:antibet/core/network/auth_interceptor.dart';
import 'package:antibet/core/network/error_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [CustomDio] é uma classe utilitária que encapsula a lógica de configuração
/// e inicialização da instância do Dio, garantindo que todos os interceptores
/// necessários sejam adicionados.
///
/// **NOTA:** Esta classe não é um Provider, mas uma factory para o Provider.
class CustomDio {
  static Dio create(Ref ref) {
    // 1. Instância base do Dio
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout:
            const Duration(seconds: AppConstants.networkTimeoutSeconds),
        receiveTimeout:
            const Duration(seconds: AppConstants.networkTimeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 2. Adiciona os Interceptores na ordem de execução correta:
    // a) AuthInterceptor: Adiciona o token (executa antes da requisição).
    dio.interceptors.add(AuthInterceptor(ref));
    
    // b) ErrorInterceptor: Trata erros de autenticação e rede (executa após a resposta/erro).
    dio.interceptors.add(ErrorInterceptor(ref));

    // Opcional: Adicionar Log/Debug Interceptor

    return dio;
  }
}

/// Provider que expõe a instância única e configurada do Dio.
/// Ele usa o [CustomDio.create] para construir a instância
/// com a [Ref] do Riverpod.
final dioProvider = Provider<Dio>((ref) {
  return CustomDio.create(ref);
});