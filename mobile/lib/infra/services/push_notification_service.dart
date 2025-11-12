import 'package:antibet_mobile/models/notification_model.dart';
import 'package:flutter/material.dart';

// Constante de simulação para o token. Em um app real, seria um token FCM.
const String _kMockFCMToken = 'mock_fcm_device_token_xyz123';

/// Camada de Serviço de Infraestrutura para Notificações Push.
///
/// Responsável pela inicialização da plataforma de notificação (ex: Firebase),
/// gerenciamento de tokens e manipulação inicial dos payloads.
class PushNotificationService {
  // TODO: Adicionar dependência do ApiClient para enviar o token ao backend
  // final ApiClient _apiClient;
  // PushNotificationService(this._apiClient);
  
  PushNotificationService();

  /// Inicializa a plataforma de notificações (simulação FCM).
  /// Esta função é chamada no início do aplicativo.
  Future<void> initializeNotifications() async {
    debugPrint('[NotificationService] Inicializando Notificações...');
    
    // 1. Simulação de requisição de permissão
    await Future.delayed(const Duration(milliseconds: 300));
    // Em um app real, aqui estaria a chamada para FirebaseMessaging.requestPermission()
    
    // 2. Obter o token do dispositivo
    final token = await _getDeviceToken();
    
    if (token != null) {
      debugPrint('[NotificationService] Token obtido: $token');
      // 3. Enviar o token para o Backend
      await _sendTokenToBackend(token);
    }

    // 4. Configurar listeners de foreground, background e terminados
    _setupNotificationListeners();
  }

  /// Simula a obtenção do token de registro do dispositivo (FCM Token).
  Future<String?> _getDeviceToken() async {
    // Em um app real: return await FirebaseMessaging.instance.getToken();
    return Future.value(_kMockFCMToken);
  }

  /// Simula o envio do token do dispositivo para o Backend.
  Future<void> _sendTokenToBackend(String token) async {
    // Em um app real: _apiClient.post('/user/devices/register', body: {'fcmToken': token});
    debugPrint('[NotificationService] Token enviado para o Backend.');
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// Configura os listeners de notificação.
  void _setupNotificationListeners() {
    // Em um app real, aqui estaria FirebaseMessaging.onMessage.listen, etc.
    debugPrint('[NotificationService] Listeners de notificação configurados.');
  }

  /// Converte um payload bruto (mapa) da notificação para o modelo tipado.
  NotificationModel? parseNotificationPayload(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) {
      return null;
    }
    try {
      return NotificationModel.fromJson(payload);
    } catch (e) {
      debugPrint('[NotificationService] Erro ao parsear payload: $e');
      return null;
    }
  }

  // TODO: Adicionar método para gerenciar o clique na notificação e a navegação.
}