// mobile/lib/features/ai_chat/screens/ai_chat_screen.dart

import 'package:antibet/features/ai_chat/models/ai_chat_message_model.dart';
import 'package:antibet/features/ai_chat/notifiers/ai_chat_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 

class AiChatScreen extends StatelessWidget {
  const AiChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta as mudanças no AiChatNotifier
    final notifier = context.watch<AiChatNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistente de Análise de IA'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: notifier.startNewConversation, // Começa nova conversa
            tooltip: 'Iniciar nova conversa',
          ),
        ],
      ),
      body: Column(
        children: [
          if (notifier.errorMessage != null && !notifier.limitExceeded)
            _buildErrorBanner(notifier.errorMessage!),
            
          if (notifier.limitExceeded)
            const Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_clock, size: 64, color: Colors.amber),
                      SizedBox(height: 16),
                      Text(
                        'Limite de Interações Excedido',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Você atingiu o limite de mensagens do seu plano Básico. Assine o Premium para acesso ilimitado!',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else 
            Expanded(
              child: ListView.builder(
                reverse: true, // Para mostrar as mensagens mais recentes na parte inferior
                padding: const EdgeInsets.all(12.0),
                itemCount: notifier.messages.length,
                itemBuilder: (context, index) {
                  // Inverte a ordem para exibir corretamente de cima para baixo
                  final message = notifier.messages[notifier.messages.length - 1 - index];
                  return ChatBubble(message: message);
                },
              ),
            ),
          
          if (!notifier.limitExceeded)
            _buildInputArea(context, notifier),
        ],
      ),
    );
  }
  
  Widget _buildErrorBanner(String message) {
      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          color: Colors.red.shade100,
          child: Row(
              children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(child: Text(message, style: TextStyle(color: Colors.red.shade900))),
              ],
          ),
      );
  }

  Widget _buildInputArea(BuildContext context, AiChatNotifier notifier) {
    final TextEditingController _controller = TextEditingController();
    
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Pergunte à IA sobre suas análises...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
              enabled: !notifier.isLoading,
            ),
          ),
          const SizedBox(width: 8),
          notifier.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      notifier.sendMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                ),
        ],
      ),
    );
  }
}

/// Componente para exibir uma bolha de chat.
class ChatBubble extends StatelessWidget {
  final AiChatMessageModel message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.sender == 'user';
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(12.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue.shade500 : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isUser ? 16 : 0),
            topRight: Radius.circular(isUser ? 0 : 16),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isUser ? 'Você' : 'Assistente IA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isUser ? Colors.white70 : Colors.black54,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.content,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}