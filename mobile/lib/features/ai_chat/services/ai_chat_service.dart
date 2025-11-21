import 'package:antibet/core/data/api/api_client.dart';
// Será necessário criar o ChatMessageModel
import 'package:antibet/features/ai_chat/models/chat_message_model.dart'; 
import 'package:injectable/injectable.dart';

/// Define a interface para o serviço de comunicação com o Chat de IA (AiChat).
abstract class IAiChatService {
  /// Envia uma mensagem do usuário e recebe a resposta da IA.
  Future<ChatMessageModel> sendMessage(String messageContent);

  /// Busca o histórico de conversas do usuário.
  Future<List<ChatMessageModel>> fetchHistory();
}

/// Implementação concreta do serviço AiChat.
/// Utiliza o ApiClient para comunicação com o endpoint do módulo AiChat do Backend.
@LazySingleton(as: IAiChatService)
class AiChatService implements IAiChatService {
  final ApiClient _apiClient;

  AiChatService(this._apiClient);

  @override
  Future<ChatMessageModel> sendMessage(String messageContent) async {
    // Endpoint: POST /aichat/send
    final response = await _apiClient.post(
      '/aichat/send',
      data: {'message': messageContent},
    );
    // Assumimos que o retorno é o objeto completo da mensagem (incluindo a resposta da IA)
    return ChatMessageModel.fromJson(response.data);
  }

  @override
  Future<List<ChatMessageModel>> fetchHistory() async {
    // Endpoint: GET /aichat/history
    final response = await _apiClient.get('/aichat/history');

    // Mapeia a lista de JSONs retornada para uma lista de ChatMessageModel
    return (response.data as List)
        .map((json) => ChatMessageModel.fromJson(json))
        .toList();
  }
}