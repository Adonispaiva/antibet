import 'package:flutter/foundation.dart';
import 'package:antibet/core/models/notification_model.dart'; // Importação do Modelo correto

/// Notifier responsável por gerenciar o estado e o histórico de notificações
/// do aplicativo para o usuário.
class NotificationsNotifier extends ChangeNotifier {
  // Lista privada mutável que armazena todas as notificações (Refatorado para NotificationModel).
  List<NotificationModel> _notifications = [];

  // Getter público para acessar o histórico de notificações.
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  // Calcula o número de notificações não lidas.
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Adiciona uma nova notificação ao histórico.
  Future<void> addNotification({
    required String title,
    required String message,
  }) async {
    // Simulação de delay para operação de persistência (StorageService).
    await Future.delayed(const Duration(milliseconds: 100));

    // Cria a nova notificação (Refatorado para NotificationModel)
    final newNotification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      isRead: false,
      date: DateTime.now(),
    );
    
    // Adiciona a nova notificação no topo da lista
    _notifications.insert(0, newNotification);

    notifyListeners();
  }

  /// Marca todas as notificações como lidas.
  Future<void> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Atualiza o status de leitura para todos os itens (Refatorado para copyWith)
    _notifications = _notifications.map((n) {
      if (!n.isRead) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    notifyListeners();
  }
}