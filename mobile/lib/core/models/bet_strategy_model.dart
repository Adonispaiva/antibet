import 'package:flutter/material.dart';

@immutable
class BetStrategyModel {
  final String id;
  final String name;
  final String description;
  final bool isActive;

  const BetStrategyModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
  });

  // Método auxiliar para criar uma cópia
  BetStrategyModel copyWith({
    String? name,
    String? description,
    bool? isActive,
  }) {
    return BetStrategyModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  // Método auxiliar para criar o modelo a partir de JSON (desserialização)
  factory BetStrategyModel.fromJson(Map<String, dynamic> json) {
    return BetStrategyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      isActive: json['isActive'] as bool,
    );
  }

  // Método auxiliar para converter o modelo para JSON (serialização)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isActive': isActive,
    };
  }
}