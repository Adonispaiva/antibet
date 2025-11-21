import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:antibet/features/ai_chat/providers/ai_chat_provider.dart';
import 'package:antibet/features/ai_chat/models/chat_message_model.dart';
import 'package:antibet/features/shared/widgets/app_layout.dart'; // Importação do AppLayout
import 'package:antibet/features/shared/widgets/empty_state_widget.dart'; // Importação do EmptyStateWidget
import 'package:antibet/core/styles/app_colors.dart';


// O decorator @RoutePage é exigido pelo auto_route
@RoutePage()
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiChatProvider _chatProvider = GetIt.I<AiChatProvider>();

  @override
  void initState() {
    super.initState();
    // Carrega o histórico ao entrar na tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatProvider.loadHistory();
    });
    _chatProvider.addListener(_scrollDown);
  }

  @override
  void dispose() {
    _chatProvider.removeListener(_scrollDown);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Desce o scroll para a última mensagem.
  void _scrollDown() {
    if (_scrollController.hasClients) {
      // Adiciona um pequeno delay para garantir que a lista foi reconstruída
      Future.delayed(const Duration(milliseconds: 50), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  /// Envia a mensagem e limpa o campo de texto.
  void _handleSend() {
    if (_textController.text.trim().isEmpty || _chatProvider.isLoading) return;
    
    final message = _textController.text.trim();
    _textController.clear();

    try {
      _chatProvider.sendMessage(message);
    } catch (e) {
      // O erro é tratado no provider, aqui só garantimos que o campo limpa
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _chatProvider,
      builder: (context, child) {
        
        final bool isInitialLoading = _chatProvider.isLoading && _chatProvider.history.isEmpty;
        
        Widget content;

        // 2. Error State (apenas se não houver histórico para mostrar)
        if (_chatProvider.errorMessage != null && _chatProvider.history.isEmpty) {
          content = EmptyStateWidget.error(
            title: 'Erro de Conexão',
            subtitle: _chatProvider.errorMessage,
            action: ElevatedButton.icon(
              onPressed: _chatProvider.loadHistory,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          );
        }
        
        // 3. Empty State
        else if (_chatProvider.history.isEmpty && !_chatProvider.isLoading) {
          content = EmptyStateWidget.noData(
            title: 'Inicie uma Conversa',
            subtitle: 'Pergunte sobre estratégias, análises de trade ou tendências do mercado.',
            icon: Icons.chat_bubble_outline,
          );
        }
        
        // 4. Data Display
        else {
          content = ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0), // Padding horizontal ajustado para a lista
            itemCount: _chatProvider.history.length,
            itemBuilder: (context, index) {
              final message = _chatProvider.history[index];
              return _buildMessageBubble(message);
            },
          );
        }
        
        return AppLayout( // Substitui o Scaffold principal
          appBar: AppBar(
            title: const Text('Consultor AntiBet IA'),
          ),
          isLoading: isInitialLoading, // Apenas loading inicial, não o indicador de digitação
          useSafeArea: true,
          child: Column(
            children: [
              // Área de Exibição de Mensagens (Expanded)
              Expanded(
                child: content,
              ),
              
              // Indicador de digitação da IA
              if (_chatProvider.isLoading && _chatProvider.history.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      SizedBox(width: 8),
                      SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 10),
                      Text('Digitando...'),
                    ],
                  ),
                ),
                
              // Área de Input
              _buildTextComposer(),
            ],
          ),
        );
      },
    );
  }

  /// Constrói o widget da bolha de mensagem.
  Widget _buildMessageBubble(ChatMessageModel message) {
    final bool isUser = message.role == 'user';
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75), // Limita a largura
              decoration: BoxDecoration(
                color: isUser ? AppColors.primaryBlue : Colors.grey[300],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(15),
                  topRight: const Radius.circular(15),
                  bottomLeft: isUser ? const Radius.circular(15) : const Radius.circular(0),
                  bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(15),
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isUser ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Constrói a área de input de texto.
  Widget _buildTextComposer() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor, // Fundo do input
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              controller: _textController,
              onSubmitted: (_) => _handleSend(),
              decoration: InputDecoration(
                hintText: 'Pergunte ao Consultor IA...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.grey[200],
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: const Icon(Icons.send, color: AppColors.primaryBlue),
              onPressed: _chatProvider.isLoading ? null : _handleSend,
            ),
          ),
        ],
      ),
    );
  }
}