import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider global para acessar o serviço de Inteligência Artificial
final aiServiceProvider = Provider<AiService>((ref) => AiService());

class AiService {
  // Configuração do cliente HTTP (Dio)
  // Nota: No emulador Android, 'localhost' é acessado via '10.0.2.2'
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:3000/api',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  /// Envia uma mensagem do usuário para o Agente de IA (Backend)
  /// Retorna a resposta textual processada pelo modelo.
  Future<String> sendMessage({required String userId, required String message}) async {
    try {
      final response = await _dio.post('/ai/chat', data: {
        'userId': userId,
        'message': message,
      });

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return response.data['data']['response'];
      } else {
        throw Exception('O servidor retornou um erro: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      // Tratamento específico de erros de rede
      if (e.response != null) {
        throw Exception('Erro no Agente (${e.response?.statusCode}): ${e.response?.data['message'] ?? 'Desconhecido'}');
      } else {
        throw Exception('Falha de conexão. Verifique se o Backend está rodando.');
      }
    } catch (e) {
      throw Exception('Erro inesperado ao contatar a IA: $e');
    }
  }
}