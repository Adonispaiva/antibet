import 'package:dio/dio.dart';
import 'package:antibet_mobileapp/services/api_service.dart';

class AiChatService {
  // Injeção de dependência do Dio via ApiService singleton
  final Dio _dio = ApiService.instance;
  
  // Endpoint definido no Backend (AiChatController)
  static const String _aiChatEndpoint = '/ai-chat'; 

  /**
   * Envia a mensagem do usuário para a IA e processa a resposta.
   * Lida com o erro 403 Forbidden (limite de uso).
   * @param message A mensagem do usuário.
   * @returns A resposta da IA (texto e uso de tokens).
   */
  Future<Map<String, dynamic>> sendAiMessage(String message) async {
    try {
      final response = await _dio.post(
        _aiChatEndpoint,
        data: {
          'message': message,
        },
      );

      // Assumindo que a resposta do Backend é no formato { text: '...', tokenUsage: X }
      return response.data;
      
    } on DioError catch (e) {
      if (e.response?.statusCode == 403) {
        // Erro específico de limite de uso excedido (implementado no AiChatService do Backend)
        throw Exception('Limite de uso de IA excedido. Por favor, assine um plano.');
      }
      // Tratar outros erros de rede ou servidor (500, etc.)
      throw Exception('Falha na comunicação com a IA: ${e.message}');
    } catch (e) {
      // Erros gerais
      throw Exception('Ocorreu um erro desconhecido: $e');
    }
  }
}