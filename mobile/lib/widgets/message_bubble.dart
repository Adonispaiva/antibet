import 'package:flutter/material.dart';
import 'package:inovexa_antibet/models/chat_message.model.dart';
import 'package:inovexa_antibet/utils/app_colors.dart';
import 'package:inovexa_antibet/utils/app_typography.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUserMessage = message.author == ChatMessageAuthor.user;
    final bool isErrorMessage = message.author == ChatMessageAuthor.error;

    // Define o alinhamento e as cores com base no autor
    final alignment =
        isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isErrorMessage
        ? AppColors.error.withOpacity(0.1)
        : (isUserMessage ? AppColors.primary : AppColors.surfaceLight);
    final textColor = isErrorMessage
        ? AppColors.error
        : (isUserMessage ? AppColors.textLight : AppColors.textDark);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            constraints: BoxConstraints(
              // Limita a largura da bolha para 75% da tela
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft:
                    isUserMessage ? const Radius.circular(16) : Radius.zero,
                bottomRight:
                    isUserMessage ? Radius.zero : const Radius.circular(16),
              ),
            ),
            child: Text(
              message.text,
              style: AppTypography.body.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}