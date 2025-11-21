import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:antibet/features/notification/models/notification_model.dart';
import 'package:antibet/features/notification/services/notification_service.dart';

/// Provider (Gerenciador de Estado) para o módulo Notification.
/// Gerencia a lista de notificações, o status de leitura e o contador de notificações não lidas.
@injectable
class NotificationProvider with ChangeNotifier {
  final INotificationService _notificationService;

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters para exposição do estado
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Retorna a contagem de notificações não lidas.
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider(this._notificationService);

  /// Carrega todas as notificações do usuário.
  Future<void> fetchNotifications() async {
    if (_isLoading) return;
    _setLoading(true);

    try {
      _notifications = await _notificationService.fetchNotifications();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Falha ao carregar as notificações: ${e.toString()}';
      _notifications = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Marca uma notificação específica como lida, atualizando o estado localmente.
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);

      // Atualiza o status isRead do modelo localmente para refletir a mudança
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !_notifications[index].isRead) {
        // Cria um novo modelo (simulando copyWith) para atualizar o status isRead
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          title: _notifications[index].title,
          body: _notifications[index].body,
          type: _notifications[index].type,
          isRead: true, 
          createdAt: _notifications[index].createdAt,
        );
      }
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Falha ao marcar como lida: ${e.toString()}';
      rethrow;
    }
  }

  /// Deleta uma notificação e atualiza o estado.
  Future<void> deleteNotification(String notificationId) async {
    _setLoading(true);

    try {
      await _notificationService.deleteNotification(notificationId);
      _notifications.removeWhere((n) => n.id == notificationId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Falha ao deletar notificação: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}