/// Define os tipos de ações ou conteúdo da notificação,
/// auxiliando a lógica de navegação do aplicativo.
enum NotificationType {
  generalAlert,
  newStrategy,
  userUpdate,
  unknown,
}

/// Representa o modelo de dados de uma Notificação Push.
///
/// Esta classe é usada para deserializar o payload JSON recebido
/// e tipificar os dados usados para exibição e navegação.
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime sentTime;
  final bool isRead;
  final NotificationType type;
  final Map<String, dynamic>? data; // Dados auxiliares para navegação

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.sentTime,
    this.isRead = false,
    this.type = NotificationType.unknown,
    this.data,
  });

  /// Construtor de fábrica para criar uma instância de [NotificationModel] a partir de um Map (JSON Payload).
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Tenta extrair os dados mais profundos do payload (comum em FCM)
    final payload = json['data'] as Map<String, dynamic>? ?? json;

    final typeString = payload['type'] as String?;
    
    return NotificationModel(
      id: payload['id'] as String? ?? UniqueKey().toString(),
      title: payload['title'] as String? ?? 'Novo Alerta',
      body: payload['body'] as String? ?? 'Você tem uma nova notificação.',
      sentTime: DateTime.tryParse(payload['sentTime'] as String? ?? '') ?? DateTime.now(),
      type: _parseNotificationType(typeString),
      data: payload['data'] is Map<String, dynamic> ? payload['data'] as Map<String, dynamic> : null,
      isRead: false,
    );
  }

  /// Helper para converter string do payload para o Enum [NotificationType].
  static NotificationType _parseNotificationType(String? type) {
    switch (type?.toLowerCase()) {
      case 'newstrategy':
        return NotificationType.newStrategy;
      case 'userupdate':
        return NotificationType.userUpdate;
      case 'generalalert':
        return NotificationType.generalAlert;
      default:
        return NotificationType.unknown;
    }
  }

  /// Cria uma cópia do [NotificationModel] com campos atualizados (imutabilidade).
  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      sentTime: sentTime,
      isRead: isRead ?? this.isRead,
      type: type,
      data: data,
    );
  }
}