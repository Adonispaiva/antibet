// D:\projetos-inovexa\AntiBet\mobile\lib\screens\ai_chat\ai_chat_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antibet_mobile/utils/app_colors.dart';
import 'package:antibet_mobile/utils/app_typography.dart';
import 'package:antibet_mobile/controllers/ai_chat/ai_chat_controller.dart'; 

class AiChatScreen extends StatelessWidget {
  const AiChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AiChatController controller = Get.put(AiChatController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Oráculo IA', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.cardBackground,
        elevation: 1,
        actions: [
          // Exibição do status do plano em tempo real
          Obx(() => Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                controller.planStatus.value,
                style: AppTypography.label.copyWith(color: AppColors.secondary),
              ),
            ),
          )),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
              reverse: true, // Começa de baixo (mensagens mais recentes)
              padding: const EdgeInsets.all(12.0),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final message = controller.messages.reversed.toList()[index];
                return _buildMessageBubble(message);
              },
            )),
          ),
          
          // Indicador de digitação da IA
          Obx(() => controller.isThinking.value
              ? LinearProgressIndicator(color: AppColors.primary)
              : const SizedBox.shrink()),

          // Barra de entrada de texto
          _buildInputBar(controller),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.primary.withOpacity(0.8) : AppColors.cardBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(message.isUser ? 16 : 4),
            topRight: Radius.circular(message.isUser ? 4 : 16),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          ),
        ),
        child: Text(
          message.text,
          style: AppTypography.bodyText.copyWith(
            color: message.isUser ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(AiChatController controller) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.textController,
                style: AppTypography.bodyText.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Pergunte ao Oráculo (Ex: Próximo jogo do Palmeiras?)',
                  hintStyle: AppTypography.bodyText.copyWith(color: AppColors.textSecondary),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => controller.sendMessage(),
              ),
            ),
            Obx(() => IconButton(
              icon: Icon(Icons.send, color: controller.isThinking.value ? AppColors.textSecondary : AppColors.primary),
              onPressed: controller.isThinking.value ? null : controller.sendMessage,
            )),
          ],
        ),
      ),
    );
  }
}