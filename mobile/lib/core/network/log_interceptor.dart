import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Para verificar o modo debug

/// [LogInterceptor] é um interceptor simples do Dio que registra
/// informações sobre as requisições, respostas e erros no console.
///
/// Ele só deve ser ativo em ambientes de desenvolvimento (debug)
/// para evitar vazamento de dados em produção.
class SimpleLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('>>> [DIO REQUEST] ${options.method} ${options.uri}');
      print('Headers: ${options.headers}');
      if (options.data != null) {
        print('Data: ${options.data}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('<<< [DIO RESPONSE] ${response.statusCode} ${response.requestOptions.uri}');
      if (response.data != null) {
        // Limita o tamanho do log da resposta para não poluir o console
        final responseString = response.data.toString();
        print('Data: ${responseString.length > 500 ? '${responseString.substring(0, 500)}...' : responseString}');
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('!!! [DIO ERROR] ${err.response?.statusCode ?? err.type}');
      print('Path: ${err.requestOptions.uri}');
      if (err.response?.data != null) {
        print('Response Data: ${err.response!.data}');
      }
      print('Error Message: ${err.message}');
    }
    handler.next(err);
  }
}