// mobile/lib/core/services/ai_chat_api_service.dart

import 'dart:convert';
import 'package:antibet/core/services/auth_service.dart';
import 'package:antibet/features/ai_chat/models/ai_chat_conversation_model.dart';
import 'package:antibet/features/ai_chat/models/ai_chat_message_model.dart';
import 'package:antibet/features/ai_chat/models/ai_chat_response_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:antibet/config/app_config.dart'; // Importação do AppConfig

// const String _kAiChatApiUrl = 'http://localhost:3000/api/ai-chat'; // Removido!

class AiChatApiService {
  final AuthService _authService;

  AiChatApiService(this._authService);

  /// Helper para construir os headers com o Token JWT.
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Autenticação necessária para acessar o Chat de IA.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Injeção do token JWT
    };
  }

  /// Envia uma mensagem do usuário para a IA e obtém a resposta (POST).
  Future<AiChatResponseModel> sendMessage(String message, int? conversationId) async {
    final url = Uri.parse('${AppConfig.apiUrl}/ai-chat/message'); // Usando AppConfig

    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({
          'message': message,
          'conversationId': conversationId,
        }),
      );

      // O backend retorna 201 no sucesso, 403 no limite excedido.
      if (response.statusCode == 201 || response.statusCode == 403) {
        final data = jsonDecode(response.body);
        
        // O Backend deve retornar um AiChatResponseModel completo, independentemente do status.
        return AiChatResponseModel.fromJson(data);
      }
      
      debugPrint('AiChatApiService: Falha ao enviar mensagem. Status: ${response.statusCode}');
      throw Exception('Falha na comunicação com a IA.');
    } catch (e) {
      debugPrint('AiChatApiService: Erro de conexão ao enviar mensagem: $e');
      rethrow;
    }
  }

  /// Obtém o histórico de mensagens de uma conversa específica (GET).
  Future<List<AiChatMessageModel>> getMessages(int conversationId) async {
    final url = Uri.parse('${AppConfig.apiUrl}/ai-chat/conversations/$conversationId/messages'); // Usando AppConfig
    
    try {
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => AiChatMessageModel.fromJson(item)).toList();
      }
      
      debugPrint('AiChatApiService: Falha ao buscar mensagens. Status: ${response.statusCode}');
      throw Exception('Falha ao carregar histórico de mensagens.');
    } catch (e) {
      debugPrint('AiChatApiService: Erro de conexão ao buscar mensagens: $e');
      rethrow;
    }
  }
  
  /// Obtém a lista de conversas do usuário (GET).
  Future<List<AiChatConversationModel>> getConversations() async {
    final url = Uri.parse('${AppConfig.apiUrl}/ai-chat/conversations'); // Usando AppConfig
    
    try {
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => AiChatConversationModel.fromJson(item)).toList();
      }
      
      debugPrint('AiChatApiService: Falha ao buscar conversas. Status: ${response.statusCode}');
      throw Exception('Falha ao carregar lista de conversas.');
    } catch (e) {
      debugPrint('AiChatApiService: Erro de conexão ao buscar conversas: $e');
      rethrow;
    }
  }
}