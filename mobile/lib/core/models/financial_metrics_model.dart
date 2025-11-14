import 'package:flutter/material.dart';

@immutable
class FinancialMetricsModel {
  final double totalBalance;
  final double totalStaked;
  final double netProfitLoss;
  final double roiPercentage; // Return on Investment (e.g., 0.05 for 5%)
  final double winRate; // Win Rate (e.g., 0.60 for 60%)

  const FinancialMetricsModel({
    required this.totalBalance,
    required this.totalStaked,
    required this.netProfitLoss,
    required this.roiPercentage,
    required this.winRate,
  });

  // Construtor padrão para o estado inicial/vazio
  factory FinancialMetricsModel.initial() {
    return const FinancialMetricsModel(
      totalBalance: 0.0,
      totalStaked: 0.0,
      netProfitLoss: 0.0,
      roiPercentage: 0.0,
      winRate: 0.0,
    );
  }

  // Método auxiliar para criar o modelo a partir de JSON (desserialização)
  factory FinancialMetricsModel.fromJson(Map<String, dynamic> json) {
    return FinancialMetricsModel(
      totalBalance: (json['totalBalance'] as num).toDouble(),
      totalStaked: (json['totalStaked'] as num).toDouble(),
      netProfitLoss: (json['netProfitLoss'] as num).toDouble(),
      roiPercentage: (json['roiPercentage'] as num).toDouble(),
      winRate: (json['winRate'] as num).toDouble(),
    );
  }

  // Método auxiliar para converter o modelo para JSON (serialização)
  Map<String, dynamic> toJson() {
    return {
      'totalBalance': totalBalance,
      'totalStaked': totalStaked,
      'netProfitLoss': netProfitLoss,
      'roiPercentage': roiPercentage,
      'winRate': winRate,
    };
  }
}