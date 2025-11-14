// mobile/lib/features/ai_chat/notifiers/ai_chat_notifier.dart

import 'package:antibet/core/services/ai_chat_api_service.dart';
import 'package:antibet/features/ai_chat/models/ai_chat_conversation_model.dart';
import 'package:antibet/features/ai_chat/models/ai_chat_message_model.dart';
import 'package:flutter/foundation.dart';

/// Notifier responsável por gerenciar o estado da conversa e o histórico de mensagens do Chat de IA.
class AiChatNotifier extends ChangeNotifier {
  final AiChatApiService _aiChatApiService;

  // Estado
  List<AiChatMessageModel> _messages = [];
  List<AiChatConversationModel> _conversations = [];
  int? _currentConversationId;
  bool _isLoading = false;
  String? _errorMessage;
  bool _limitExceeded = false; // Estado de Gating do recurso

  AiChatNotifier(this._aiChatApiService) {
    // Carrega o histórico de conversas na inicialização
    fetchConversations();
  }

  // Getters para a UI
  List<AiChatMessageModel> get messages => _messages;
  List<AiChatConversationModel> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get limitExceeded => _limitExceeded;
  int? get currentConversationId => _currentConversationId;

  /// Inicia uma nova conversa, limpando as mensagens atuais.
  void startNewConversation() {
    _messages = [];
    _currentConversationId = null;
    _limitExceeded = false;
    notifyListeners();
  }
  
  /// Carrega o histórico de conversas do usuário.
  Future<void> fetchConversations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _conversations = await _aiChatApiService.getConversations();
    } catch (e) {
      _errorMessage = 'Falha ao carregar histórico de conversas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega as mensagens de uma conversa específica.
  Future<void> loadConversation(int conversationId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _messages = await _aiChatApiService.getMessages(conversationId);
      _currentConversationId = conversationId;
    } catch (e) {
      _errorMessage = 'Falha ao carregar mensagens da conversa: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Envia a mensagem do usuário para a API e processa a resposta da IA.
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty || _limitExceeded) return;

    // 1. Adiciona a mensagem do usuário ao estado (para feedback visual imediato)
    final userMessage = AiChatMessageModel(
        id: -1, // ID temporário
        conversationId: _currentConversationId ?? -1,
        content: message,
        sender: 'user',
        createdAt: DateTime.now());
    _messages.add(userMessage);
    _isLoading = true; // Inicia o estado de espera pela resposta da IA
    notifyListeners();

    try {
      // 2. Envia para a API (que gerencia a persistência e a lógica de LLM)
      final response = await _aiChatApiService.sendMessage(message, _currentConversationId);

      // 3. Processa a resposta
      _limitExceeded = response.limitExceeded;

      if (response.limitExceeded) {
        // Remove a mensagem do usuário (ou exibe um erro no lugar da resposta da IA)
        _messages.removeLast(); 
        _errorMessage = response.message;
      } else {
        // Adiciona a resposta da IA ao estado
        final aiMessage = AiChatMessageModel(
            id: -1, // ID temporário
            conversationId: response.conversationId,
            content: response.message,
            sender: 'ai',
            createdAt: DateTime.now());
        
        // Remove a mensagem temporária do usuário (-1) e adiciona a mensagem real do usuário (se necessário) e a resposta da IA.
        _messages.removeWhere((m) => m.id == -1); 
        _messages.add(aiMessage);
        
        _currentConversationId = response.conversationId;
      }

      // 4. Atualiza o histórico de conversas se uma nova foi criada
      if (_currentConversationId != null && 
          !_conversations.any((c) => c.id == _currentConversationId)) {
            fetchConversations(); // Recarrega o histórico
      }

    } catch (e) {
      _messages.removeLast(); 
      _errorMessage = 'Erro de comunicação com a IA.';
      debugPrint('AiChatNotifier Send Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}