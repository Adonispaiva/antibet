/// Representa o modelo de dados para métricas financeiras consolidadas.
///
/// Usado para calcular e exibir o desempenho financeiro do usuário
/// com base no seu histórico de apostas (Bet Journal).
class FinancialMetricsModel {
  final double returnOnInvestment; // ROI em percentual (ex: 0.15 para 15%)
  final double totalProfitLoss;    // Balanço total (lucro líquido)
  final double totalStaked;        // Total de dinheiro apostado
  final int totalBets;             // Total de apostas registradas
  final double averageStake;       // Stake média
  final double winRatePercentage;  // Taxa de vitória (%)

  FinancialMetricsModel({
    required this.returnOnInvestment,
    required this.totalProfitLoss,
    required this.totalStaked,
    required this.totalBets,
    required this.averageStake,
    required this.winRatePercentage,
  });

  /// Construtor de fábrica para criar uma instância a partir do JSON (API).
  factory FinancialMetricsModel.fromJson(Map<String, dynamic> json) {
    return FinancialMetricsModel(
      returnOnInvestment: (json['returnOnInvestment'] as num?)?.toDouble() ?? 0.0,
      totalProfitLoss: (json['totalProfitLoss'] as num?)?.toDouble() ?? 0.0,
      totalStaked: (json['totalStaked'] as num?)?.toDouble() ?? 0.0,
      totalBets: json['totalBets'] as int? ?? 0,
      averageStake: (json['averageStake'] as num?)?.toDouble() ?? 0.0,
      winRatePercentage: (json['winRatePercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Construtor de 'estado vazio' para inicialização (ex: estado de loading).
  factory FinancialMetricsModel.empty() {
    return FinancialMetricsModel(
      returnOnInvestment: 0.0,
      totalProfitLoss: 0.0,
      totalStaked: 0.0,
      totalBets: 0,
      averageStake: 0.0,
      winRatePercentage: 0.0,
    );
  }
}