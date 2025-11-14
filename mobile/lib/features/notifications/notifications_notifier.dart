// mobile/lib/features/notifications/notifiers/notifications_notifier.dart

import 'package:antibet/core/services/notifications_service.dart'; // O serviço refatorado
import 'package:antibet/features/notifications/models/notification_model.dart'; // O modelo tipado
import 'package:flutter/foundation.dart';

/// Notifier responsável por gerenciar e expor a lista de notificações do usuário à UI.
class NotificationsNotifier extends ChangeNotifier {
  final NotificationsService _notificationsService;

  // Estado
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  NotificationsNotifier(this._notificationsService) {
    // Carrega as notificações na inicialização
    fetchNotifications();
  }

  // Getters para a UI
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Retorna o número de notificações não lidas (crucial para o ícone de sino).
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Obtém a lista de notificações do serviço (Backend/Persistência Local) e atualiza o estado.
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _notificationsService.loadNotifications();
      // Ordena por data (mais recente primeiro)
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp)); 
    } catch (e) {
      _errorMessage = 'Falha ao carregar notificações: $e';
      debugPrint('NotificationsNotifier Error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adiciona uma nova notificação ao estado (usado por outros módulos que criam alertas).
  void addNotificationLocally(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }
  
  /// Marca uma notificação específica como lida e atualiza o estado.
  Future<void> markAsRead(int notificationId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !_notifications[index].isRead) {
        // 1. Atualiza no serviço (persistência)
        final updatedNotification = _notifications[index].copyWith(isRead: true);
        
        // Em um cenário real, chamaria o Service para persistir a mudança no Backend.
        // await _notificationsService.updateNotification(updatedNotification); 
        
        // 2. Atualiza o estado local
        _notifications[index] = updatedNotification;
        debugPrint('Notificação marcada como lida: ID $notificationId');
      }
    } catch (e) {
      _errorMessage = 'Falha ao marcar como lida: $e';
      debugPrint('NotificationsNotifier Error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Marca todas as notificações não lidas como lidas e atualiza o estado.
  Future<void> markAllAsRead() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // 1. Atualiza no serviço (persistência)
      await _notificationsService.markAllAsRead(); 
      
      // 2. Atualiza o estado local (em lote)
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();

    } catch (e) {
      _errorMessage = 'Falha ao marcar todas como lidas: $e';
      debugPrint('NotificationsNotifier Error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}