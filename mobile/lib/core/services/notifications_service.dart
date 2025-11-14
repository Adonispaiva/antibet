// mobile/lib/core/services/notifications_service.dart

import 'dart:convert';
import 'package:antibet/core/services/auth_service.dart';
import 'package:antibet/features/notifications/models/notification_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// A URL da API do Backend.
const String _kApiUrl = 'http://localhost:3000/api/notifications';

class NotificationsService {
  final AuthService _authService;

  NotificationsService(this._authService);

  /// Helper para construir os headers com o Token JWT.
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Autenticação necessária para acessar Notificações.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Injeção do token JWT
    };
  }

  /// Obtém a lista de notificações do Backend (GET).
  Future<List<NotificationModel>> getNotifications() async {
    final url = Uri.parse(_kApiUrl);
    
    try {
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => NotificationModel.fromJson(item)).toList();
      }
      
      debugPrint('NotificationsService: Falha ao buscar notificações. Status: ${response.statusCode}');
      throw Exception('Falha ao carregar notificações.');
    } catch (e) {
      debugPrint('NotificationsService: Erro de conexão ao buscar notificações: $e');
      rethrow;
    }
  }

  /// Marca uma notificação específica como lida (PATCH).
  Future<void> markAsRead(int notificationId) async {
    final url = Uri.parse('$_kApiUrl/$notificationId/read');
    
    try {
      final response = await http.patch(
        url,
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        debugPrint('NotificationsService: Falha ao marcar como lida. Status: ${response.statusCode}');
        throw Exception('Falha na atualização do status da notificação.');
      }
    } catch (e) {
      debugPrint('NotificationsService: Erro de conexão ao marcar como lida: $e');
      rethrow;
    }
  }

  /// Marca todas as notificações como lidas (PATCH).
  Future<void> markAllAsRead() async {
    final url = Uri.parse('$_kApiUrl/read-all');
    
    try {
      final response = await http.patch(
        url,
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        debugPrint('NotificationsService: Falha ao marcar todas como lidas. Status: ${response.statusCode}');
        throw Exception('Falha na atualização de todas as notificações.');
      }
    } catch (e) {
      debugPrint('NotificationsService: Erro de conexão ao marcar todas como lidas: $e');
      rethrow;
    }
  }
}