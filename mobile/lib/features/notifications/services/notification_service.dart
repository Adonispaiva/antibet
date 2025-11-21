import 'package:antibet/core/data/api/api_client.dart';
// Será necessário criar o NotificationModel
import 'package:antibet/features/notification/models/notification_model.dart';
import 'package:injectable/injectable.dart';

/// Define a interface para o serviço de gestão de Notificações (Notification).
abstract class INotificationService {
  /// Busca todas as notificações do usuário.
  Future<List<NotificationModel>> fetchNotifications();

  /// Marca uma notificação específica como lida.
  Future<void> markAsRead(String id);

  /// Deleta uma notificação pelo seu ID.
  Future<void> deleteNotification(String id);
}

/// Implementação concreta do serviço Notification.
/// Utiliza o ApiClient para comunicação com os endpoints do módulo Notification do Backend.
@LazySingleton(as: INotificationService)
class NotificationService implements INotificationService {
  final ApiClient _apiClient;

  NotificationService(this._apiClient);

  @override
  Future<List<NotificationModel>> fetchNotifications() async {
    // Endpoint: GET /notification
    final response = await _apiClient.get('/notification');

    // Mapeia a lista de JSONs retornada para uma lista de NotificationModel
    return (response.data as List)
        .map((json) => NotificationModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> markAsRead(String id) async {
    // Endpoint: PATCH /notification/:id/read
    await _apiClient.patch('/notification/$id/read', data: {});
  }

  @override
  Future<void> deleteNotification(String id) async {
    // Endpoint: DELETE /notification/:id
    await _apiClient.delete('/notification/$id');
  }
}