// D:\projetos-inovexa\AntiBet\mobile\lib\services\api_service.dart

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:antibet_mobile/utils/app_constants.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Para armazenamento seguro

class ApiService extends GetxService {
  late Dio _dio;
  // final _storage = const FlutterSecureStorage();

  @override
  void onInit() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.BASE_URL,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
      ),
    );

    // Adiciona Interceptores
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Exemplo: Injetar o Token JWT no cabeçalho
        // final token = await _storage.read(key: 'jwt_token');
        // if (token != null) {
        //   options.headers['Authorization'] = 'Bearer $token';
        // }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Tratamento Global de Erros HTTP (401, 403, 500)
        if (e.response?.statusCode == 401) {
          // Lógica de deslogar o usuário ou refresh token
          print('Erro 401: Não autorizado. Redirecionando para Login.');
        }
        return handler.next(e); // Propaga o erro
      },
    ));
    super.onInit();
  }

  // --- MÉTODOS HTTP GENÉRICOS ---

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, dynamic data) async {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, dynamic data) async {
    return _dio.put(path, data: data);
  }
  
  // Outros métodos DELETE/PATCH...
}

// Inicializa o serviço globalmente ao iniciar o aplicativo
Future<void> initServices() async {
  Get.put(ApiService());
}