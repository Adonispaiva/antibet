import 'package:json_annotation/json_annotation.dart';

part 'chat_message_model.g.dart'; // Arquivo de geração de código (Json Serializer)

/// Modelo de Dados para uma Mensagem de Chat com a IA.
/// Utiliza json_annotation para garantir desserialização e serialização seguras e tipadas.
@JsonSerializable()
class ChatMessageModel {
  @JsonKey(name: '_id') // Mapeamento para o campo ID do MongoDB/Backend
  final String id;
  final String role; // 'user' ou 'assistant'
  final String content; // O texto da mensagem
  final DateTime timestamp;
  final String? sessionId; // ID da sessão ou conversa (opcional)

  ChatMessageModel({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.sessionId,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageModelToJson(this);
}