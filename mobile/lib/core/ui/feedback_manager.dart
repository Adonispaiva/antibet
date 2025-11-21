import 'package:flutter/material.dart';

/// Gerenciador centralizado de feedback visual (Snackbars).
/// Utiliza o ScaffoldMessenger para exibir mensagens globais no app.
class FeedbackManager {
  // Cor privada para garantir consistência com o tema, mas hardcoded para feedback semântico
  static const Color _successColor = Color(0xFF2E7D32); // Green 800
  static const Color _errorColor = Color(0xFFC62828);   // Red 800
  static const Color _infoColor = Color(0xFF0277BD);    // Light Blue 800

  /// Exibe uma mensagem de SUCESSO (Fundo Verde)
  static void showSuccess(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      backgroundColor: _successColor,
      icon: Icons.check_circle_outline,
    );
  }

  /// Exibe uma mensagem de ERRO (Fundo Vermelho)
  /// Útil para falhas de API, validação ou exceções.
  static void showError(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      backgroundColor: _errorColor,
      icon: Icons.error_outline,
      duration: const Duration(seconds: 4), // Erros precisam de mais tempo para ler
    );
  }

  /// Exibe uma mensagem INFORMATIVA (Fundo Azul)
  static void showInfo(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      backgroundColor: _infoColor,
      icon: Icons.info_outline,
    );
  }

  /// Método privado genérico para construção da UI do Snackbar
  static void _showSnackbar(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    // Remove snackbars anteriores para evitar empilhamento excessivo
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating, // Flutua sobre a UI (mais moderno)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: duration,
        elevation: 4,
        margin: const EdgeInsets.all(16), // Margem ao redor para o efeito flutuante
      ),
    );
  }
}