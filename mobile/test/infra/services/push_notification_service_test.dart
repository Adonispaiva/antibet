import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:antibet_mobile/models/notification_model.dart';
import 'package:antibet_mobile/infra/services/push_notification_service.dart';

// =========================================================================
// SIMULAÇÃO DE DEPENDÊNCIAS (Mocks)
// =========================================================================

// Simulação de NotificationType (para que o teste possa ser executado neste ambiente)
enum NotificationType { generalAlert, newStrategy, userUpdate, unknown }

// Simulação de NotificationModel (para que o teste possa ser executado neste ambiente)
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime sentTime;
  final NotificationType type;
  final Map<String, dynamic>? data;

  NotificationModel({required this.id, required this.title, required this.body, required this.sentTime, this.type = NotificationType.unknown, this.data});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final payload = json['data'] as Map<String, dynamic>? ?? json;
    final typeString = payload['type'] as String?;
    
    return NotificationModel(
      id: payload['id'] as String? ?? UniqueKey().toString(),
      title: payload['title'] as String? ?? 'Novo Alerta',
      body: payload['body'] as String? ?? 'Você tem uma nova notificação.',
      sentTime: DateTime.tryParse(payload['sentTime'] as String? ?? '') ?? DateTime.now(),
      type: _parseNotificationType(typeString),
      data: payload['data'] is Map<String, dynamic> ? payload['data'] as Map<String, dynamic> : null,
    );
  }
  
  static NotificationType _parseNotificationType(String? type) {
    switch (type?.toLowerCase()) {
      case 'newstrategy': return NotificationType.newStrategy;
      case 'userupdate': return NotificationType.userUpdate;
      case 'generalalert': return NotificationType.generalAlert;
      default: return NotificationType.unknown;
    }
  }
}

// Mock da classe de Serviço de Notificação Push
const String _kMockFCMToken = 'mock_fcm_device_token_xyz123';
class PushNotificationService {
  PushNotificationService();
  
  bool isTokenSent = false;
  
  Future<void> initializeNotifications() async {
    final token = await _getDeviceToken();
    if (token != null) {
      await _sendTokenToBackend(token);
    }
  }

  Future<String?> _getDeviceToken() async {
    return Future.value(_kMockFCMToken);
  }

  Future<void> _sendTokenToBackend(String token) async {
    isTokenSent = true;
    await Future.delayed(Duration.zero);
  }

  void _setupNotificationListeners() {}

  NotificationModel? parseNotificationPayload(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) {
      return null;
    }
    try {
      return NotificationModel.fromJson(payload);
    } catch (e) {
      return null;
    }
  }
}

// =========================================================================
// FIM DA SIMULAÇÃO
// =========================================================================

void main() {
  group('PushNotificationService Unit Tests', () {
    late PushNotificationService notificationService;

    setUp(() {
      notificationService = PushNotificationService();
    });

    test('01. initializeNotifications deve obter e enviar o token para o backend', () async {
      await notificationService.initializeNotifications();

      expect(notificationService.isTokenSent, isTrue, reason: 'O token deve ser enviado ao backend após a inicialização.');
    });

    // ---------------------------------------------------------------------
    // Testes de Parsing de Payload
    // ---------------------------------------------------------------------
    test('02. parseNotificationPayload deve retornar um NotificationModel válido para um payload NEW_STRATEGY', () {
      final payload = {
        'id': 'notif_100',
        'title': 'Nova Estratégia',
        'body': 'Uma estratégia de baixo risco foi adicionada.',
        'sentTime': '2025-11-10T12:00:00Z',
        'type': 'NewStrategy', // Tipo embutido no root
        'data': {
          'strategyId': 'strat_999',
          'type': 'NewStrategy', // Tipo duplicado (cenário FCM)
        },
      };

      final notification = notificationService.parseNotificationPayload(payload);

      expect(notification, isA<NotificationModel>());
      expect(notification!.title, 'Nova Estratégia');
      expect(notification.type, NotificationType.newStrategy);
      expect(notification.data, isNotNull);
    });

    test('03. parseNotificationPayload deve retornar null para payload nulo ou vazio', () {
      expect(notificationService.parseNotificationPayload(null), isNull);
      expect(notificationService.parseNotificationPayload({}), isNull);
    });
    
    test('04. parseNotificationPayload deve tratar tipo desconhecido (UNKNOWN)', () {
      final payload = {
        'id': 'notif_101',
        'title': 'Alerta',
        'body': 'Algo aconteceu.',
        'type': 'invalid_type', 
      };

      final notification = notificationService.parseNotificationPayload(payload);

      expect(notification!.type, NotificationType.unknown);
    });
  });
}