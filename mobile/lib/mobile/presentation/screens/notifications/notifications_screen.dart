import 'package:antibet/core/notifiers/push_notification_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationNotifier = context.watch<PushNotificationNotifier>();
    final notifications = notificationNotifier.notifications;
    final isLoading = notificationNotifier.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          // Ação para Marcar Todas como Lidas
          TextButton(
            onPressed: notificationNotifier.unreadCount > 0 
                ? notificationNotifier.markAllAsRead 
                : null,
            child: const Text('Mark All Read', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(
                  child: Text(
                    'You have no new notifications.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    
                    return Dismissible(
                      key: Key(notification.id), // Chave para permitir o Dismiss
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        // Simula a remoção da notificação
                        notificationNotifier.removeNotification(notification.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${notification.title} dismissed.')),
                        );
                      },
                      child: ListTile(
                        leading: Icon(
                          notification.isRead ? Icons.email_outlined : Icons.mail,
                          color: notification.isRead ? Colors.grey : Theme.of(context).primaryColor,
                        ),
                        title: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          notification.body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          '${notification.timestamp.hour}:${notification.timestamp.minute}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        onTap: () {
                          if (!notification.isRead) {
                            notificationNotifier.markAsRead(notification.id);
                          }
                          // Opcional: Navegar para detalhes da notificação
                        },
                      ),
                    );
                  },
                ),
    );
  }
}