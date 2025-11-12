import 'package:antibet_mobile/infra/services/push_notification_service.dart';
import 'package:antibet_mobile/models/notification_model.dart';
import 'package:flutter/material.dart';

/// Gerencia o estado e a lógica de negócios para as Notificações Push.
///
/// Responsável por manter a lista de alertas e coordenar o serviço
/// para o recebimento e processamento de payloads.
class PushNotificationNotifier with ChangeNotifier {
  final PushNotificationService _notificationService;

  // Lista de notificações (Simulando o que viria do Storage ou API)
  final List<NotificationModel> _notifications = []; 
  
  // Construtor com injeção de dependência
  PushNotificationNotifier(this._notificationService) {
    // Inicia a plataforma de notificação no boot do Notifier
    _notificationService.initializeNotifications();
    
    // TODO: Em uma versão real, o PushNotificationService chamaria um callback aqui
    // para notificar o Notifier sobre novas mensagens recebidas.
    // Ex: _notificationService.onNotificationReceived = _onNewNotification;
    
    // Simulação de carregamento de notificações antigas
    _simulateInitialLoad();
  }

  // Getters públicos
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  
  /// Retorna a contagem de notificações não lidas.
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Marca uma notificação específica como lida.
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    
    if (index != -1 && !_notifications[index].isRead) {
      // Cria uma cópia imutável com isRead = true
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      
      // TODO: Em uma versão real, isto seria persistido no Storage ou Backend.
      notifyListeners();
      debugPrint('[NotificationNotifier] Notificação marcada como lida: $notificationId');
    }
  }

  /// Adiciona uma nova notificação à lista (Usado em simulação ou callback real).
  void addNewNotification(NotificationModel notification) {
    // Adiciona ao início da lista (as mais novas primeiro)
    _notifications.insert(0, notification);
    
    // TODO: Em uma versão real, esta notificação seria salva no Storage.
    notifyListeners();
    debugPrint('[NotificationNotifier] Nova notificação recebida: ${notification.title}');
  }

  /// Simulação de um fluxo de notificação.
  void _simulateInitialLoad() {
    _notifications.addAll([
      NotificationModel(
        id: '002',
        title: 'Nova Estratégia de Risco Médio',
        body: 'A estratégia "Gol HT (Médio Risco)" foi adicionada à sua lista.',
        sentTime: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: true,
        type: NotificationType.newStrategy,
        data: {'strategyId': 'strat_999'},
      ),
      NotificationModel(
        id: '001',
        title: 'Bem-vindo ao AntiBet!',
        body: 'Obrigado por se juntar à nossa comunidade. Explore seu dashboard.',
        sentTime: DateTime.now().subtract(const Duration(days: 1)),
        isRead: false,
        type: NotificationType.generalAlert,
      ),
    ]);
    notifyListeners();
  }
}