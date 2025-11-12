/// Define o nível de risco associado a uma estratégia.
enum StrategyRiskLevel { low, medium, high, unknown }

/// Representa o modelo de dados de uma Estratégia de Aposta (Bet Strategy).
///
/// Usado para deserializar (fromJson) os dados vindos da API
/// e gerenciar o estado no [BetStrategyNotifier].
class StrategyModel {
  final String id;
  final String title;
  final String description;
  final StrategyRiskLevel riskLevel;
  final double? winRatePercentage; // Percentual de 0.0 a 100.0
  final DateTime? lastAnalyzed;

  StrategyModel({
    required this.id,
    required this.title,
    required this.description,
    this.riskLevel = StrategyRiskLevel.unknown,
    this.winRatePercentage,
    this.lastAnalyzed,
  });

  /// Construtor de fábrica para criar uma instância de [StrategyModel] a partir de um Map (JSON).
  factory StrategyModel.fromJson(Map<String, dynamic> json) {
    return StrategyModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      riskLevel: _parseRiskLevel(json['riskLevel'] as String?),
      winRatePercentage: (json['winRatePercentage'] as num?)?.toDouble(),
      lastAnalyzed: json['lastAnalyzed'] != null
          ? DateTime.tryParse(json['lastAnalyzed'] as String)
          : null,
    );
  }

  /// Converte a instância de [StrategyModel] em um Map (JSON).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'riskLevel': riskLevel.name, // Converte enum para string
      'winRatePercentage': winRatePercentage,
      'lastAnalyzed': lastAnalyzed?.toIso8601String(),
    };
  }

  /// Helper para converter string (da API) para o Enum [StrategyRiskLevel].
  static StrategyRiskLevel _parseRiskLevel(String? level) {
    switch (level?.toLowerCase()) {
      case 'low':
        return StrategyRiskLevel.low;
      case 'medium':
        return StrategyRiskLevel.medium;
      case 'high':
        return StrategyRiskLevel.high;
      default:
        return StrategyRiskLevel.unknown;
    }
  }

  /// Cria uma cópia do [StrategyModel] com campos atualizados (imutabilidade).
  StrategyModel copyWith({
    String? id,
    String? title,
    String? description,
    StrategyRiskLevel? riskLevel,
    double? winRatePercentage,
    DateTime? lastAnalyzed,
  }) {
    return StrategyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      riskLevel: riskLevel ?? this.riskLevel,
      winRatePercentage: winRatePercentage ?? this.winRatePercentage,
      lastAnalyzed: lastAnalyzed ?? this.lastAnalyzed,
    );
  }

  @override
  String toString() {
    return 'StrategyModel(id: $id, title: "$title", risk: ${riskLevel.name})';
  }
}