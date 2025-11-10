import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:antibet/src/core/notifiers/user_profile_notifier.dart';

// O avatar da IA (simulação)
const String _iaAvatarPath = 'assets/images/lumen_avatar.png'; 
const String _iaName = 'AntiBet Coach';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  
  @override
  void initState() {
    super.initState();
    // Mensagem de boas-vindas inicial da IA (simulação do check-in)
    _addInitialMessage();
  }
  
  void _addInitialMessage() {
    final userNickname = context.read<UserProfileNotifier>().nickname;
    // Baseado na filosofia: acolhedora, check-in diário
    final initialMessage = 'Olá, $userNickname. Como você está se sentindo hoje? Pensei em apostar? Lembre-se, estou aqui para te ouvir sem julgamentos.'; 

    _messages.insert(0, {
      'text': initialMessage,
      'sender': _iaName,
    });
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    // 1. Adiciona a mensagem do usuário (na frente da lista)
    setState(() {
      _messages.insert(0, {
        'text': text,
        'sender': context.read<UserProfileNotifier>().nickname,
      });
    });

    // 2. Simula a resposta da IA após um pequeno atraso (em produção, chamaria a API do LLM)
    _textController.clear();
    FocusScope.of(context).unfocus(); // Fecha o teclado
    
    // Simulação de resposta da IA (sem lógica de LLM aqui)
    Future.delayed(const Duration(seconds: 1), () {
      _messages.insert(0, {
        'text': 'Entendo o que você está sentindo. É difícil, mas você tem o controle. Quer tentar a técnica de respiração?', 
        'sender': _iaName,
      });
      // Em um projeto real, aqui seria o ponto de chamada do Orquestrador IA
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat com AntiBet Coach'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
        actions: [
          // Botão de Informações/Limites (para o Modo Premium)
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Simulação de navegação para a tela de limites/planos
              context.push('/chat/limits'); 
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Área de Exibição das Mensagens
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true, // Mostra as mensagens mais recentes na parte inferior
              itemCount: _messages.length,
              itemBuilder: (_, int index) => _buildMessageBubble(_messages[index], context),
            ),
          ),
          const Divider(height: 1.0),
          // Área de Entrada de Texto
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  // Constrói o widget de entrada de texto
  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration.collapsed(hintText: 'Converse com o AntiBet Coach...'),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Constrói a bolha de mensagem (Bubble)
  Widget _buildMessageBubble(Map<String, String> message, BuildContext context) {
    final bool isUser = message['sender'] != _iaName;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          if (!isUser) // Mensagem da IA
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                // Simulação do avatar (Lúmen ou outro avatar) 
                backgroundColor: Colors.blueGrey[100], 
                child: const Icon(Icons.psychology_alt, color: Colors.blueGrey),
              ),
            ),
          
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  message['sender'] ?? 'Desconhecido',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isUser ? Colors.blue : Colors.blueGrey,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.blue[100] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    message['text'] ?? '',
                    style: TextStyle(color: isUser ? Colors.black87 : Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}