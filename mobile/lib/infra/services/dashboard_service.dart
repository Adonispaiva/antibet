import 'dart:async';

// Placeholder temporário para o modelo de Dados do Dashboard
// Este modelo deve ser definido em 'mobile/lib/domain/models/dashboard_model.dart' futuramente.
class DashboardModel {
  final double overallProfitPercentage;
  final int totalAlerts;
  final String lastStrategyUsed;

  DashboardModel({
    required this.overallProfitPercentage,
    required this.totalAlerts,
    required this.lastStrategyUsed,
  });
  
  // Placeholder para desserialização
  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      overallProfitPercentage: json['overallProfitPercentage'] ?? 0.0,
      totalAlerts: json['totalAlerts'] ?? 0,
      lastStrategyUsed: json['lastStrategyUsed'] ?? 'Nenhuma',
    );
  }
}

// O DashboardService é responsável por buscar dados analíticos e sumarizados
// do Backend para serem exibidos na tela inicial do usuário (Home/Dashboard).
class DashboardService {
  
  // Construtor
  DashboardService();

  // 1. Simulação da chamada de API para buscar o conteúdo completo do Dashboard
  Future<DashboardModel> fetchDashboardContent() async {
    // -----------------------------------------------------------------
    // TODO: Implementar a chamada HTTP real (GET /dashboard/summary)
    // -----------------------------------------------------------------

    // Simulação de delay de rede/processamento
    await Future.delayed(const Duration(milliseconds: 700));

    // Simulação de dados do Dashboard
    return DashboardModel(
      overallProfitPercentage: 8.45, // Exemplo: 8.45% de lucro geral
      totalAlerts: 3,
      lastStrategyUsed: 'Strategy-v2.1',
    );
  }

  // 2. Simulação da chamada para atualizar/refrescar uma seção específica
  Future<List<String>> fetchQuickMetrics() async {
     // -----------------------------------------------------------------
    // TODO: Implementar a chamada HTTP real para métricas rápidas
    // -----------------------------------------------------------------
    await Future.delayed(const Duration(milliseconds: 300));
    return ['+8.45% Lucro', '3 Alertas', '12 Vitórias'];
  }
}