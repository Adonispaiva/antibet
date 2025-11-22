import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../services/ai_service.dart';

// === MODELO DE MENSAGEM (Simplificado para o Chat) ===
class ChatMessage {
  final String id;
  final String text;
  final bool isUser; // true = Usuário, false = IA
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

// === ESTADO DO CHAT ===
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? errorMessage;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Se passar null, limpa o erro? Aqui assumimos substituição direta.
    );
  }
}

// === PROVIDER DO CONTROLLER DE CHAT ===
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return ChatNotifier(aiService);
});

// === LOGICA DE NEGOCIO (CONTROLLER) ===
class ChatNotifier extends StateNotifier<ChatState> {
  final AiService _aiService;
  final _uuid = const Uuid();

  ChatNotifier(this._aiService) : super(ChatState(messages: []));

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsgId = _uuid.v4();
    final userMessage = ChatMessage(
      id: userMsgId,
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    // 1. Adiciona mensagem do usuário e ativa loading
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      errorMessage: null,
    );

    try {
      // TODO: Pegar o ID real do usuário autenticado futuramente
      const userId = "user_mvp_123"; 

      // 2. Chama o Serviço de IA (Backend)
      final aiResponseText = await _aiService.sendMessage(
        userId: userId,
        message: text,
      );

      final aiMessage = ChatMessage(
        id: _uuid.v4(),
        text: aiResponseText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      // 3. Adiciona resposta da IA e remove loading
      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );

    } catch (e) {
      // 4. Tratamento de Erro
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Erro ao conectar com AntiBet AI: ${e.toString()}",
      );
      
      // Adiciona uma mensagem de erro visual no chat também, se desejar
      final errorMessage = ChatMessage(
        id: _uuid.v4(),
        text: "⚠️ Não consegui processar sua mensagem. Tente novamente.",
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      state = state.copyWith(
        messages: [...state.messages, errorMessage],
      );
    }
  }
  
  void clearChat() {
    state = ChatState(messages: []);
  }
}