/// Representa o modelo de dados de resumo do Dashboard.
///
/// Usado para deserializar (fromJson) os dados consolidados vindos da API
/// e gerenciar o estado no [DashboardNotifier].
class DashboardSummaryModel {
  final int totalStrategies;
  final double averageWinRate;
  final int lowRiskStrategies;
  final int mediumRiskStrategies;
  final int highRiskStrategies;
  final int newStrategiesToday;

  DashboardSummaryModel({
    required this.totalStrategies,
    required this.averageWinRate,
    required this.lowRiskStrategies,
    required this.mediumRiskStrategies,
    required this.highRiskStrategies,
    required this.newStrategiesToday,
  });

  /// Construtor de fábrica para criar uma instância de [DashboardSummaryModel] a partir de um Map (JSON).
  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      totalStrategies: json['totalStrategies'] as int? ?? 0,
      averageWinRate: (json['averageWinRate'] as num?)?.toDouble() ?? 0.0,
      lowRiskStrategies: json['lowRiskStrategies'] as int? ?? 0,
      mediumRiskStrategies: json['mediumRiskStrategies'] as int? ?? 0,
      highRiskStrategies: json['highRiskStrategies'] as int? ?? 0,
      newStrategiesToday: json['newStrategiesToday'] as int? ?? 0,
    );
  }

  /// Converte a instância de [DashboardSummaryModel] em um Map (JSON).
  Map<String, dynamic> toJson() {
    return {
      'totalStrategies': totalStrategies,
      'averageWinRate': averageWinRate,
      'lowRiskStrategies': lowRiskStrategies,
      'mediumRiskStrategies': mediumRiskStrategies,
      'highRiskStrategies': highRiskStrategies,
      'newStrategiesToday': newStrategiesToday,
    };
  }

  /// Construtor de 'estado vazio' para inicialização (ex: estado de loading).
  factory DashboardSummaryModel.empty() {
    return DashboardSummaryModel(
      totalStrategies: 0,
      averageWinRate: 0.0,
      lowRiskStrategies: 0,
      mediumRiskStrategies: 0,
      highRiskStrategies: 0,
      newStrategiesToday: 0,
    );
  }
}