import 'package:flutter/foundation.dart';

/// Entidade de Domínio que representa o conteúdo agregado para o Dashboard.
/// Esta entidade é agnóstica e construída a partir de dados de múltiplos serviços (Agregação).
@immutable
class DashboardContentModel {
  // Exemplo de métrica principal
  final int totalBetsAnalyzed; 
  
  // Alerta para o usuário
  final String? recentActivityTitle; 
  
  // Exemplo de dado complexo (placeholder para futura entidade)
  final double currentBalance; 

  const DashboardContentModel({
    required this.totalBetsAnalyzed,
    required this.recentActivityTitle,
    required this.currentBalance,
  });

  /// Construtor de fábrica para desserialização JSON (API/Cache)
  factory DashboardContentModel.fromJson(Map<String, dynamic> json) {
    return DashboardContentModel(
      totalBetsAnalyzed: json['totalBetsAnalyzed'] as int? ?? 0,
      recentActivityTitle: json['recentActivityTitle'] as String?,
      currentBalance: (json['currentBalance'] as num? ?? 0.0).toDouble(),
    );
  }

  /// Método para serialização JSON (Cache/API)
  Map<String, dynamic> toJson() {
    return {
      'totalBetsAnalyzed': totalBetsAnalyzed,
      'recentActivityTitle': recentActivityTitle,
      'currentBalance': currentBalance,
    };
  }

  /// Cria uma cópia da entidade, opcionalmente com novos valores (imutabilidade)
  DashboardContentModel copyWith({
    int? totalBetsAnalyzed,
    String? recentActivityTitle,
    double? currentBalance,
  }) {
    return DashboardContentModel(
      totalBetsAnalyzed: totalBetsAnalyzed ?? this.totalBetsAnalyzed,
      recentActivityTitle: recentActivityTitle ?? this.recentActivityTitle,
      currentBalance: currentBalance ?? this.currentBalance,
    );
  }

  // Sobrescreve hashCode e equals
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DashboardContentModel &&
      other.totalBetsAnalyzed == totalBetsAnalyzed &&
      other.recentActivityTitle == recentActivityTitle &&
      other.currentBalance == currentBalance;
  }

  @override
  int get hashCode {
    return totalBetsAnalyzed.hashCode ^
      recentActivityTitle.hashCode ^
      currentBalance.hashCode;
  }
}