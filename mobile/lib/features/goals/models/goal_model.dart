import 'package:json_annotation/json_annotation.dart';

part 'goal_model.g.dart'; // Arquivo de geração de código (Json Serializer)

/// Modelo de Dados para uma Meta (Goal).
/// Utiliza json_annotation para garantir desserialização e serialização seguras e tipadas.
@JsonSerializable()
class GoalModel {
  @JsonKey(name: '_id') // Mapeamento para o campo ID do MongoDB/Backend
  final String id;
  final String title; 
  final String description; 
  final double targetValue; // Valor alvo da meta (ex: ganho financeiro)
  final double currentValue; // Progresso atual em relação ao alvo
  final DateTime startDate;
  final DateTime endDate;
  final String status; // Ex: 'ACTIVE', 'COMPLETED', 'EXPIRED'

  GoalModel({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.currentValue,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) =>
      _$GoalModelFromJson(json);

  Map<String, dynamic> toJson() => _$GoalModelToJson(this);
}