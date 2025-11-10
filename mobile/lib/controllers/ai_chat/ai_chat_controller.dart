// D:\projetos-inovexa\AntiBet\mobile\lib\controllers\ai_chat\ai_chat_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antibet_mobile/services/ai_chat_service.dart';

// Modelo simplificado para a mensagem de chat
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

class AiChatController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isThinking = false.obs;
  final RxString planStatus = 'Free Plan (5/5)'.obs; // Estado do plano/uso
  
  late final AiChatService _chatService;

  @override
  void onInit() {
    super.onInit();
    // Inicia o serviço de chat aqui.
    _chatService = Get.put(AiChatService()); 
    // Mensagem de boas-vindas inicial
    messages.add(ChatMessage(
      text: "Olá! Sou o Oráculo AntiBet, sua inteligência artificial para análise de dados esportivos. Qual a sua dúvida ou cenário de aposta?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void sendMessage() async {
    final userMessage = textController.text.trim();
    if (userMessage.isEmpty || isThinking.value) return;

    // 1. Adiciona a mensagem do usuário
    messages.add(ChatMessage(text: userMessage, isUser: true, timestamp: DateTime.now()));
    textController.clear();
    isThinking.value = true;
    
    try {
      // 2. Chama o serviço de API
      final response = await _chatService.sendAiMessage(userMessage);

      // 3. Adiciona a resposta da IA
      messages.add(ChatMessage(
        text: response['aiResponse'] ?? "Não consegui obter uma resposta.",
        isUser: false,
        timestamp: DateTime.now(),
      ));
      
      // 4. Atualiza o status do plano (Se o backend retornar)
      if (response['newPlanStatus'] != null) {
        planStatus.value = response['newPlanStatus'];
      }

    } catch (e) {
      // 5. Adiciona a mensagem de erro da IA
      messages.add(ChatMessage(
        text: "Erro na consulta: $e",
        isUser: false,
        timestamp: DateTime.now(),
      ));
      Get.snackbar('Consulta Falhou', e.toString(), snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade600, colorText: Colors.white);

    } finally {
      isThinking.value = false;
    }
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}