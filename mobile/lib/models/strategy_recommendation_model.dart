/// Define o modelo de dados para uma recomendação de estratégia.
///
/// Este modelo representa a saída do motor de IA/Análise, indicando qual
/// estratégia o usuário deve focar e por quê.
class StrategyRecommendationModel {
  final String strategyId;
  final String rationale; // O motivo da recomendação (ex: "Bom ROI em risco baixo")
  final double confidenceScore; // Pontuação de 0.0 a 1.0
  final String reasonCode; // Código interno para UI/Debugging (ex: 'ROI_LOW_RISK')

  StrategyRecommendationModel({
    required this.strategyId,
    required this.rationale,
    required this.confidenceScore,
    required this.reasonCode,
  });

  /// Construtor de fábrica para criar uma instância a partir do JSON (API).
  factory StrategyRecommendationModel.fromJson(Map<String, dynamic> json) {
    return StrategyRecommendationModel(
      strategyId: json['strategyId'] as String? ?? 'unknown',
      rationale: json['rationale'] as String? ?? 'Sem motivo definido.',
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.0,
      reasonCode: json['reasonCode'] as String? ?? 'NO_CODE',
    );
  }

  /// Construtor de 'estado vazio' para inicialização (ex: estado de loading).
  factory StrategyRecommendationModel.empty() {
    return StrategyRecommendationModel(
      strategyId: 'none',
      rationale: 'Aguardando dados para gerar recomendações...',
      confidenceScore: 0.0,
      reasonCode: 'EMPTY',
    );
  }
}