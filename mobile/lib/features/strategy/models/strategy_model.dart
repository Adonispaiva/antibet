import 'package:json_annotation/json_annotation.dart';

part 'strategy_model.g.dart'; // Arquivo de geração de código (Json Serializer)

/// Modelo de Dados para uma Estratégia de Trading.
/// Utiliza json_annotation para garantir desserialização e serialização seguras e tipadas.
@JsonSerializable()
class StrategyModel {
  @JsonKey(name: '_id') // Mapeamento para o campo ID do MongoDB/Backend
  final String id;
  final String name; 
  final String description; 
  final String type; // Ex: 'Scalping', 'Day Trade', 'Swing'
  final bool isActive;
  final DateTime createdAt;

  StrategyModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.isActive,
    required this.createdAt,
  });

  factory StrategyModel.fromJson(Map<String, dynamic> json) =>
      _$StrategyModelFromJson(json);

  Map<String, dynamic> toJson() => _$StrategyModelToJson(this);
}