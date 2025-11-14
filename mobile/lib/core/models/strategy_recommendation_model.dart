import 'package:flutter/material.dart';

@immutable
class StrategyRecommendationModel {
  final String id;
  final String title;
  final String rationale; // O Racional/Justificativa da recomendação
  final double confidenceScore; // Pontuação de Confiança (0.0 a 1.0)
  final String? recommendedStrategyId; // ID da estratégia recomendada, se aplicável

  const StrategyRecommendationModel({
    required this.id,
    required this.title,
    required this.rationale,
    required this.confidenceScore,
    this.recommendedStrategyId,
  });

  // Construtor padrão para o estado inicial/vazio
  factory StrategyRecommendationModel.initial() {
    return const StrategyRecommendationModel(
      id: 'none',
      title: 'No Active Recommendation',
      rationale: 'The system is currently analyzing your data. Check back later.',
      confidenceScore: 0.0,
      recommendedStrategyId: null,
    );
  }

  // Método auxiliar para criar o modelo a partir de JSON (desserialização)
  factory StrategyRecommendationModel.fromJson(Map<String, dynamic> json) {
    return StrategyRecommendationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      rationale: json['rationale'] as String,
      // Garante que o número seja lido como double
      confidenceScore: (json['confidenceScore'] as num).toDouble(), 
      recommendedStrategyId: json['recommendedStrategyId'] as String?,
    );
  }

  // Método auxiliar para converter o modelo para JSON (serialização)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'rationale': rationale,
      'confidenceScore': confidenceScore,
      'recommendedStrategyId': recommendedStrategyId,
    };
  }
}