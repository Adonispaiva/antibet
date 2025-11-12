import 'package:antibet_mobile/models/notification_model.dart';
import 'package:antibet_mobile/notifiers/push_notification_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Tela de Listagem de Notificações (Alertas Push).
///
/// Exibe a lista de alertas gerenciada pelo [PushNotificationNotifier].
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Observa o Notifier para atualizações na lista
    final notifier = context.watch<PushNotificationNotifier>();
    final notifications = notifier.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        centerTitle: true,
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text('Nenhum alerta recente.'),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationTile(context, notification, notifier);
              },
            ),
    );
  }

  /// Constrói o item da lista de notificações.
  Widget _buildNotificationTile(
    BuildContext context,
    NotificationModel notification,
    PushNotificationNotifier notifier,
  ) {
    // Define o estilo para destaque de notificação não lida
    final bool isUnread = !notification.isRead;
    final Color? leadingColor = isUnread ? Theme.of(context).colorScheme.primary : Colors.grey.shade600;

    return ListTile(
      leading: Icon(
        _getIconForType(notification.type),
        color: leadingColor,
      ),
      tileColor: isUnread ? Theme.of(context).cardColor.withOpacity(0.5) : null,
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        notification.body,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _formatTime(notification.sentTime),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: () {
        // 1. Marca como lida
        notifier.markAsRead(notification.id);

        // 2. TODO: Implementar lógica de navegação profunda (Deep Linking)
        _handleDeepLink(context, notification);
      },
    );
  }

  /// Helper para formatar a hora de envio da notificação.
  String _formatTime(DateTime sentTime) {
    final now = DateTime.now();
    final difference = now.difference(sentTime);

    if (difference.inHours < 1) {
      return '${difference.inMinutes}m atrás';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h atrás';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d atrás';
    } else {
      return '${sentTime.day}/${sentTime.month}';
    }
  }
  
  /// Helper para retornar o ícone baseado no tipo de notificação.
  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.newStrategy:
        return Icons.rocket_launch_outlined;
      case NotificationType.generalAlert:
        return Icons.info_outline;
      case NotificationType.userUpdate:
        return Icons.person_outline;
      case NotificationType.unknown:
      default:
        return Icons.notifications_outlined;
    }
  }
  
  /// Lógica preliminar para tratar a navegação profunda (Deep Link).
  void _handleDeepLink(BuildContext context, NotificationModel notification) {
    // Exemplo: Se for uma notificação de Nova Estratégia, navegar para os detalhes
    if (notification.type == NotificationType.newStrategy && notification.data != null) {
      final strategyId = notification.data!['strategyId'] as String?;
      if (strategyId != null) {
        // TODO: Em um cenário real, você buscará a estratégia usando o ID antes de navegar.
        // Navigator.of(context).pushNamed(AppRouter.strategyDetailRoute, arguments: strategyObject);
        debugPrint('[DeepLink] Navegando para estratégia ID: $strategyId');
      }
    }
  }
}