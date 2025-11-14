// mobile/lib/features/goals/models/goal_model.dart

import 'package:flutter/foundation.dart'; // Para listEquals e debugPrint
import 'dart:convert'; // Para jsonEncode/jsonDecode (se necessário, mas usado no service)

/// Modelo de dados para representar uma Meta financeira ou de engajamento do usuário no AntiBet.
class GoalModel {
  final int? id; // Opcional, será gerado localmente pelo service ou pela API
  final String title;
  final String description;
  final double targetAmount; // Valor alvo (R\$)
  final double currentAmount; // Progresso atual (R\$)
  final bool isCompleted;
  final DateTime creationDate;
  final DateTime? completionDate; // Nulo se não concluída

  const GoalModel({
    this.id,
    required this.title,
    this.description = '',
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.isCompleted = false,
    required this.creationDate,
    this.completionDate,
  });

  /// Constrói um GoalModel a partir de um mapa JSON.
  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      isCompleted: json['isCompleted'] as bool,
      creationDate: DateTime.parse(json['creationDate'] as String),
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'] as String)
          : null,
    );
  }

  /// Converte o GoalModel para um mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'isCompleted': isCompleted,
      'creationDate': creationDate.toIso8601String(), // Padrão universal para data/hora
      'completionDate': completionDate?.toIso8601String(),
    };
  }
  
  /// Cria uma cópia imutável do GoalModel com valores opcionais substituídos.
  GoalModel copyWith({
    int? id,
    String? title,
    String? description,
    double? targetAmount,
    double? currentAmount,
    bool? isCompleted,
    DateTime? creationDate,
    DateTime? completionDate,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      isCompleted: isCompleted ?? this.isCompleted,
      creationDate: creationDate ?? this.creationDate,
      // Note o uso de 'completionDate' nulo para permitir a remoção de uma data
      completionDate: completionDate != null
          ? completionDate
          : this.completionDate,
    );
  }

  // Omitindo a sobrecarga de hashCode e operator == por não serem cruciais para a persistência.
}