// mobile/lib/features/plans/models/plan_model.dart

/// Modelo de dados para representar um plano de assinatura do AntiBet.
/// Garante tipagem forte para a camada de Estado e UI.
class PlanModel {
  final int id;
  final String name;
  final double price;
  final String period; // Ex: 'mês', 'ano'
  final List<String> features;
  final bool isPopular;

  const PlanModel({
    required this.id,
    required this.name,
    required this.price,
    required this.period,
    required this.features,
    required this.isPopular,
  });

  /// Constrói um PlanModel a partir de um mapa JSON.
  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(), // Suporta int ou double do JSON
      period: json['period'] as String,
      features: List<String>.from(json['features'] as List),
      isPopular: json['isPopular'] as bool,
    );
  }

  /// Converte o PlanModel para um mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'period': period,
      'features': features,
      'isPopular': isPopular,
    };
  }
  
  /// Cria uma cópia imutável do PlanModel com valores opcionais substituídos.
  PlanModel copyWith({
    int? id,
    String? name,
    double? price,
    String? period,
    List<String>? features,
    bool? isPopular,
  }) {
    return PlanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      period: period ?? this.period,
      features: features ?? this.features,
      isPopular: isPopular ?? this.isPopular,
    );
  }

  // Sobrescrita do toString() para melhor debug
  @override
  String toString() {
    return 'PlanModel(id: $id, name: $name, price: $price, period: $period, isPopular: $isPopular)';
  }

  // Sobrescrita de hashCode e operator == para comparações de igualdade
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PlanModel &&
        other.id == id &&
        other.name == name &&
        other.price == price &&
        other.period == period &&
        listEquals(other.features, features) && // Requer import 'package:flutter/foundation.dart';
        other.isPopular == isPopular;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        price.hashCode ^
        period.hashCode ^
        features.hashCode ^
        isPopular.hashCode;
  }
}

// Nota: listEquals é uma função utilitária do Flutter para comparar listas. 
// A alternativa seria implementar uma lógica de comparação de lista manual 
// ou usar pacotes como collection/equatable. Para este contexto, assume-se a 
// disponibilidade de 'package:flutter/foundation.dart'.