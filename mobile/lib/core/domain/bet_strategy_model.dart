import 'package:flutter/foundation.dart';

/// Entidade de Domínio que representa uma Estratégia de Aposta ou Análise.
/// Esta entidade é central para a lógica de negócio do AntiBet.
@immutable
class BetStrategyModel {
  final String id;
  final String name;
  final String description;
  final double riskFactor; // Fator de Risco (Ex: 0.1 a 1.0)
  final bool isActive; // Se a estratégia está sendo aplicada

  const BetStrategyModel({
    required this.id,
    required this.name,
    required this.description,
    required this.riskFactor,
    this.isActive = true,
  });

  /// Construtor de fábrica para desserialização JSON (API/Cache)
  factory BetStrategyModel.fromJson(Map<String, dynamic> json) {
    return BetStrategyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      riskFactor: (json['riskFactor'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Método para serialização JSON (API/Cache)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'riskFactor': riskFactor,
      'isActive': isActive,
    };
  }

  /// Cria uma cópia da entidade, opcionalmente com novos valores (imutabilidade)
  BetStrategyModel copyWith({
    String? id,
    String? name,
    String? description,
    double? riskFactor,
    bool? isActive,
  }) {
    return BetStrategyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      riskFactor: riskFactor ?? this.riskFactor,
      isActive: isActive ?? this.isActive,
    );
  }

  // Sobrescreve hashCode e equals
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BetStrategyModel &&
      other.id == id &&
      other.name == name &&
      other.description == description &&
      other.riskFactor == riskFactor &&
      other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      riskFactor.hashCode ^
      isActive.hashCode;
  }
}