import 'package:flutter/material.dart';
import 'package:inovexa_antibet/models/chat_message.model.dart';
import 'package:inovexa_antibet/providers/ai_chat_provider.dart';
import 'package:inovexa_antibet/widgets/app_layout.dart';
import 'package:inovexa_antibet/widgets/chat_input_bar.dart';
import 'package:inovexa_antibet/widgets/message_bubble.dart';
import 'package:provider/provider.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Rola para o final da lista quando novas mensagens são adicionadas
  void _scrollToBottom(int messageCount) {
    if (messageCount > 0) {
      // Adiciona um pequeno atraso para garantir que a UI renderizou
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos 'watch' aqui para que a tela seja reconstruída
    // quando o provider notificar mudanças (novas mensagens, loading)
    final chatProvider = context.watch<AiChatProvider>();
    final messages = chatProvider.messages;

    _scrollToBottom(messages.length);

    return AppLayout(
      title: 'Assistente AntiBet',
      showAppBar: true,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return MessageBubble(message: message);
              },
            ),
          ),
          
          // Barra de Input
          ChatInputBar(
            isLoading: chatProvider.isLoading,
            onSend: (text) {
              // Delega a ação para o provider
              chatProvider.sendMessage(text);
            },
          ),
        ],
      ),
    );
  }
}