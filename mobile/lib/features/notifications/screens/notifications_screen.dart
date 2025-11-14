// mobile/lib/features/notifications/screens/notifications_screen.dart

import 'package:antibet/features/notifications/models/notification_model.dart';
import 'package:antibet/features/notifications/notifiers/notifications_notifier.dart';
import 'package:flutter/material.dart';
// Assumindo o uso de Provider/Riverpod para gerenciar o estado
import 'package:provider/provider.dart'; 
import 'package:intl/intl.dart'; // Para formatação de data (necessita do pacote intl)

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta as mudanças no NotificationsNotifier
    final notifier = context.watch<NotificationsNotifier>();
    final notifications = notifier.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        centerTitle: true,
        actions: [
          if (notifier.unreadCount > 0)
            TextButton(
              onPressed: () => notifier.markAllAsRead(),
              child: const Text(
                'Marcar todas como lidas',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: notifier.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifier.errorMessage != null
              ? Center(child: Text('Erro: ${notifier.errorMessage}'))
              : notifications.isEmpty
                  ? const Center(
                      child: Text('Você não tem notificações novas.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8.0),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return NotificationTile(
                          notification: notification,
                          onTap: () => notifier.markAsRead(notification.id!),
                        );
                      },
                    ),
    );
  }
}

/// Widget reutilizável para exibir uma notificação individual.
class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: notification.isRead ? Colors.white : Colors.blue.shade50,
      child: ListTile(
        leading: Icon(
          notification.isRead ? Icons.notifications_none : Icons.notifications_active,
          color: notification.isRead ? Colors.grey : Colors.blue,
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(notification.timestamp),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : const Icon(Icons.circle, size: 10, color: Colors.blue), // Indicador de não lida
        onTap: onTap,
      ),
    );
  }
}