import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:antibet/core/network/interceptors/auth_interceptor.dart'; 
import 'package:antibet/core/network/interceptors/error_interceptor.dart';
import 'package:antibet/core/network/interceptors/simple_log_interceptor.dart'; // Mencionada no relatório (QA)
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Para integração futura com o AuthNotifier

/// Provedor da URL base da API (pode ser substituído em testes/produção)
final baseUrlProvider = Provider<String>((ref) {
  // TODO: Substituir pela variável de ambiente real
  return 'https://api.antibet.com.br/v1'; 
});

/// Provedor centralizado do Dio (singleton) que injeta as dependências.
/// Este provider deve ser usado em todos os services (e.g., AuthService, JournalService).
final dioProvider = Provider<Dio>((ref) {
  return CustomDio.instance(ref);
});

class CustomDio {
  static Dio? _instance;
  
  // Utiliza o Ref do Riverpod para permitir que os Interceptors acessem outros providers (e.g., AuthNotifier)
  static Dio instance(Ref ref) {
    if (_instance == null) {
      final dio = Dio(
        BaseOptions(
          baseUrl: ref.read(baseUrlProvider),
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          contentType: 'application/json',
        ),
      );

      // 1. Interceptor de Segurança: Injeta o Token JWT em todas as requisições
      dio.interceptors.add(AuthInterceptor(ref: ref)); 

      // 2. Interceptor de QA: Logging simples (opcional, útil em DEBUG)
      if (kDebugMode) {
        dio.interceptors.add(SimpleLogInterceptor());
      }
      
      // 3. Interceptor de Erro: Trata erros 401/403 forçando logout
      dio.interceptors.add(ErrorInterceptor(ref: ref)); 

      _instance = dio;
    }
    return _instance!;
  }
}

// Interceptor simples para fins de QA (conforme relatório)
class SimpleLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('DIO REQUEST[${options.method}] => PATH: ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('DIO RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('DIO ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.uri}');
    handler.next(err);
  }
}