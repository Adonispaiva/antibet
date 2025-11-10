import 'package:flutter/material.dart';
import 'package:inovexa_antibet/utils/app_colors.dart';

class ChatInputBar extends StatefulWidget {
  final bool isLoading;
  final Function(String) onSend;

  const ChatInputBar({
    super.key,
    required this.isLoading,
    required this.onSend,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _textController = TextEditingController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() {
        _canSend = _textController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_canSend && !widget.isLoading) {
      widget.onSend(_textController.text.trim());
      _textController.clear();
      FocusScope.of(context).unfocus(); // Esconde o teclado
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: AppColors.textDark.withOpacity(0.1), width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Digite sua mensagem...',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  filled: false, // O input bar já tem o fundo
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _handleSubmit(),
                enabled: !widget.isLoading,
              ),
            ),
            const SizedBox(width: 8),
            // Botão de Envio ou Indicador de Loading
            widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(Icons.send_rounded),
                    color: AppColors.primary,
                    onPressed: _canSend ? _handleSubmit : null,
                  ),
          ],
        ),
      ),
    );
  }
}