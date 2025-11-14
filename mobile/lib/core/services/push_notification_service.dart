import 'package:antibet/core/models/notification_model.dart';
import 'package:antibet/core/services/storage_service.dart';

class PushNotificationService {
  final StorageService _storageService;
  static const String _notificationsKey = 'push_notifications';

  PushNotificationService(this._storageService);

  /// Simula a carga de todas as notificações do armazenamento.
  List<NotificationModel> loadNotifications() {
    // Para simulação inicial, vamos adicionar algumas notificações se o storage estiver vazio.
    final currentList = _storageService.loadList<NotificationModel>(
      _notificationsKey,
      NotificationModel.fromJson,
    );
    
    // Adiciona dados mockados na primeira carga se estiver vazio, para facilitar o teste da UI
    if (currentList.isEmpty) {
      return [
        NotificationModel(
          id: 'n1',
          title: 'Welcome to AntiBet!',
          body: 'Your account is ready. Start tracking your bets now.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          isRead: false,
        ),
        NotificationModel(
          id: 'n2',
          title: 'ROI Alert',
          body: 'Your 7-day ROI reached 5%. Great job!',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          isRead: false,
        ),
        NotificationModel(
          id: 'n3',
          title: 'System Update',
          body: 'New financial metrics calculation method deployed.',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
        ),
      ];
    }
    
    return currentList;
  }

  /// Adiciona e persiste uma nova notificação.
  Future<bool> addNotification(NotificationModel newNotification) async {
    final currentList = loadNotifications();
    // Adiciona a nova notificação no início
    final updatedList = [newNotification, ...currentList];
    
    return await _storageService.saveList<NotificationModel>(
      _notificationsKey,
      updatedList,
      (n) => n.toJson(),
    );
  }
  
  /// Marca uma notificação específica como lida.
  Future<bool> markAsRead(String notificationId) async {
    final currentList = loadNotifications();
    
    final updatedList = currentList.map((n) {
      return n.id == notificationId ? n.copyWith(isRead: true) : n;
    }).toList();
    
    return await _storageService.saveList<NotificationModel>(
      _notificationsKey,
      updatedList,
      (n) => n.toJson(),
    );
  }

  /// Remove uma notificação específica.
  Future<bool> removeNotification(String notificationId) async {
    final currentList = loadNotifications();
    final updatedList = currentList.where((n) => n.id != notificationId).toList();
    
    return await _storageService.saveList<NotificationModel>(
      _notificationsKey,
      updatedList,
      (n) => n.toJson(),
    );
  }

  /// Marca todas as notificações como lidas.
  Future<bool> markAllAsRead() async {
    final currentList = loadNotifications();
    
    final updatedList = currentList.map((n) {
      return n.copyWith(isRead: true);
    }).toList();
    
    return await _storageService.saveList<NotificationModel>(
      _notificationsKey,
      updatedList,
      (n) => n.toJson(),
    );
  }
}