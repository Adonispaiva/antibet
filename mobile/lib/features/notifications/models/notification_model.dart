import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart'; // Arquivo de geração de código (Json Serializer)

/// Modelo de Dados para uma Notificação.
/// Utiliza json_annotation para garantir desserialização e serialização seguras e tipadas.
@JsonSerializable()
class NotificationModel {
  @JsonKey(name: '_id') // Mapeamento para o campo ID do MongoDB/Backend
  final String id;
  final String title; 
  final String body; // Conteúdo principal da notificação
  final String type; // Ex: 'ALERT', 'SYSTEM', 'JOURNAL_UPDATE'
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}