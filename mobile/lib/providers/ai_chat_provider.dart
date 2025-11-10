import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:inovexa_antibet/models/chat_message.model.dart';
import 'package:inovexa_antibet/providers/auth_provider.dart';
import 'package:inovexa_antibet/services/api_service.dart';

class AiChatProvider with ChangeNotifier {
  final AuthProvider _authProvider; // Dependência para obter o token

  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  // Construtor que recebe a dependência do AuthProvider
  AiChatProvider(this._authProvider) {
    // Adiciona uma mensagem de boas-vindas inicial da IA
    _messages.add(
      ChatMessage(
        text: 'Olá! Estou aqui para ajudar você a entender e superar seus desafios. Como você está se sentindo hoje?',
        author: ChatMessageAuthor.model,
      ),
    );
  }

  /// Envia uma nova mensagem do usuário para a IA e processa a resposta.
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Adiciona a mensagem do usuário à UI imediatamente
    final userMessage = ChatMessage(
      text: text,
      author: ChatMessageAuthor.user,
    );
    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    try {
      // Garante que estamos autenticados (o ApiService já foi configurado pelo AuthProvider no login)
      if (_authProvider.token == null) {
        throw Exception('Usuário não autenticado.');
      }

      // 2. Envia a requisição para o backend
      // (O token JWT já está nos headers do apiService.dio)
      final response = await apiService.dio.post(
        '/ai-chat/interaction',
        data: {'prompt': text},
      );

      // 3. Processa a resposta da IA
      if (response.statusCode == 201 && response.data['response'] != null) {
        final modelMessage = ChatMessage(
          text: response.data['response'],
          author: ChatMessageAuthor.model,
        );
        _messages.add(modelMessage);
      } else {
        throw Exception('Resposta inesperada da API.');
      }
    } on DioException catch (e) {
      _handleError('Erro de rede: ${e.message}');
    } catch (e) {
      _handleError('Erro ao processar: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adiciona uma mensagem de erro à lista de chat
  void _handleError(String errorText) {
    _messages.add(
      ChatMessage(
        text: 'Desculpe, ocorreu um erro. Tente novamente.\n($errorText)',
        author: ChatMessageAuthor.error,
      ),
    );
  }
}