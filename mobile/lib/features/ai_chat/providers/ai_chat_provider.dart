import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:antibet/features/ai_chat/models/chat_message_model.dart';
import 'package:antibet/features/ai_chat/services/ai_chat_service.dart';

/// Provider (Gerenciador de Estado) para o módulo AiChat.
/// Gerencia o histórico da conversa e o envio de novas mensagens.
@injectable
class AiChatProvider with ChangeNotifier {
  final IAiChatService _aiChatService;

  List<ChatMessageModel> _history = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters para exposição do estado
  List<ChatMessageModel> get history => _history;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AiChatProvider(this._aiChatService);

  /// Carrega o histórico de mensagens da sessão atual ou do usuário.
  Future<void> loadHistory() async {
    if (_isLoading) return;
    _setLoading(true);

    try {
      _history = await _aiChatService.fetchHistory();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Falha ao carregar o histórico do chat: ${e.toString()}';
      _history = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Envia uma mensagem do usuário, atualiza a lista e aguarda a resposta da IA.
  Future<void> sendMessage(String messageContent) async {
    // 1. Adiciona a mensagem do usuário ao histórico (Atualização Otimista)
    final userMessage = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: messageContent,
      timestamp: DateTime.now(),
    );
    _history = [..._history, userMessage];
    notifyListeners(); 
    
    _setLoading(true);

    try {
      // 2. Chama o serviço para obter a resposta da IA
      final aiResponse = await _aiChatService.sendMessage(messageContent);
      
      // 3. Adiciona a resposta da IA ao histórico
      _history = [..._history, aiResponse]; 
      
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Falha ao enviar mensagem ou receber resposta da IA: ${e.toString()}';
      _history.removeLast(); // Rollback da mensagem do usuário
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}