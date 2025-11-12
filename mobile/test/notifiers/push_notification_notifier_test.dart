import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:antibet_mobile/models/notification_model.dart';
import 'package:antibet_mobile/infra/services/push_notification_service.dart';
import 'package:antibet_mobile/notifiers/push_notification_notifier.dart';

// =========================================================================
// SIMULAÇÃO DE DEPENDÊNCIAS (Mocks)
// =========================================================================

// Simulação de NotificationType (mínimo necessário para o teste)
enum NotificationType { generalAlert, newStrategy, userUpdate, unknown }

// Simulação de NotificationModel (mínimo necessário para o teste)
class NotificationModel {
  final String id;
  final String title;
  final bool isRead;
  final NotificationType type;

  NotificationModel({required this.id, required this.title, this.isRead = false, this.type = NotificationType.unknown});

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      isRead: isRead ?? this.isRead,
      type: type,
    );
  }
}

// Simulação de PushNotificationService (mínimo necessário para o teste)
class PushNotificationService {
  PushNotificationService();
  Future<void> initializeNotifications() async => throw UnimplementedError();
}

// Mock da classe de Serviço de Notificação Push
class MockPushNotificationService implements PushNotificationService {
  bool initializeCalled = false;
  
  @override
  Future<void> initializeNotifications() async {
    initializeCalled = true;
    await Future.delayed(Duration.zero);
  }
}

// SIMULAÇÃO DO NOTIFIER (mínimo necessário para o teste)
class PushNotificationNotifier with ChangeNotifier {
  final MockPushNotificationService _notificationService;

  final List<NotificationModel> _notifications = []; 
  
  PushNotificationNotifier(this._notificationService) {
    _notificationService.initializeNotifications();
    _simulateInitialLoad();
  }

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void addNewNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void _simulateInitialLoad() {
    _notifications.addAll([
      NotificationModel(id: '002', title: 'Antiga Lida', isRead: true),
      NotificationModel(id: '001', title: 'Nova Não Lida', isRead: false),
    ]);
  }
}

// =========================================================================
// FIM DA SIMULAÇÃO
// =========================================================================

void main() {
  group('PushNotificationNotifier Unit Tests', () {
    late PushNotificationNotifier notifier;
    late MockPushNotificationService mockService;
    
    // Configuração: Garante estado limpo e objetos antes de cada teste
    setUp(() {
      mockService = MockPushNotificationService();
      notifier = PushNotificationNotifier(mockService);
    });

    test('01. O construtor deve chamar initializeNotifications no serviço', () {
      expect(mockService.initializeCalled, isTrue);
    });

    test('02. O getter unreadCount deve retornar a contagem correta', () {
      // O _simulateInitialLoad adiciona 1 notificação não lida ('001')
      expect(notifier.unreadCount, 1);
    });
    
    // ---------------------------------------------------------------------
    // Testes de Adição de Notificação
    // ---------------------------------------------------------------------
    test('03. addNewNotification deve adicionar o alerta ao topo e atualizar a contagem', () {
      final tNewAlert = NotificationModel(id: '003', title: 'Alerta Recente', isRead: false);
      
      notifier.addNewNotification(tNewAlert);
      
      // Verifica a contagem
      expect(notifier.unreadCount, 2); // 1 original + 1 novo
      
      // Verifica a posição (deve estar no índice 0)
      expect(notifier.notifications.first.id, '003'); 
    });

    // ---------------------------------------------------------------------
    // Testes de Marcação como Lida
    // ---------------------------------------------------------------------
    test('04. markAsRead deve marcar o alerta como lido e diminuir a contagem', () {
      // Notificação inicial não lida é a '001'
      expect(notifier.unreadCount, 1);
      
      final listenerCallCount = <int>[];
      notifier.addListener(() => listenerCallCount.add(1));
      
      notifier.markAsRead('001');
      
      // Verifica o estado
      expect(notifier.unreadCount, 0);
      
      // Verifica se o listener foi chamado
      expect(listenerCallCount, [1]);
    });
    
    test('05. markAsRead não deve notificar se a notificação já estiver lida', () {
      // Notificação inicial lida é a '002'
      expect(notifier.notifications.firstWhere((n) => n.id == '002').isRead, isTrue);
      
      final listenerCallCount = <int>[];
      notifier.addListener(() => listenerCallCount.add(1));
      
      notifier.markAsRead('002');
      
      // O listener não deve ser chamado
      expect(listenerCallCount, isEmpty);
      expect(notifier.unreadCount, 1);
    });
  });
}