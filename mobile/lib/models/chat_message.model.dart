/// Define o autor de uma mensagem no chat
enum ChatMessageAuthor {
  user,  // Mensagem enviada pelo usuário
  model, // Mensagem recebida da IA (GPT, Gemini, etc.)
  error, // Mensagem de erro do sistema
}

/// Modelo de dados para uma única mensagem na interface de chat.
class ChatMessage {
  final String text;
  final ChatMessageAuthor author;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.author,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}