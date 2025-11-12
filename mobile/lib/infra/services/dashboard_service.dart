import 'package:antibet_mobile/models/dashboard_summary_model.dart';
import 'package:flutter/material.dart';

/// Camada de Serviço de Infraestrutura para o Dashboard.
///
/// Responsável pela lógica de negócios e comunicação com a API (Backend)
/// referente aos dados consolidados do dashboard.
class DashboardService {
  // Simulação de dependência de um cliente HTTP (ex: Dio, Http)
  // final ApiClient _apiClient;
  // DashboardService(this._apiClient);

  DashboardService() {
    // Construtor vazio por enquanto
  }

  /// Busca os dados de resumo (summary) do dashboard.
  Future<DashboardSummaryModel> getDashboardSummary() async {
    try {
      // 1. Simulação de chamada de rede
      debugPrint('[DashboardService] Buscando resumo do dashboard...');
      await Future.delayed(const Duration(milliseconds: 650));

      // 2. Simulação de dados JSON recebidos da API
      final Map<String, dynamic> mockApiResponse = {
        'totalStrategies': 42,
        'averageWinRate': 78.5,
        'lowRiskStrategies': 15,
        'mediumRiskStrategies': 20,
        'highRiskStrategies': 7,
        'newStrategiesToday': 3,
      };

      // 3. Parsing dos dados usando o DashboardSummaryModel.fromJson
      final summary = DashboardSummaryModel.fromJson(mockApiResponse);

      debugPrint('[DashboardService] Resumo recebido.');
      return summary;

    } catch (e) {
      // TODO: Implementar logging de erro robusto.
      debugPrint('[DashboardService] Erro ao buscar resumo: $e');
      throw Exception('Falha ao carregar dados do dashboard.');
    }
  }

  // Outros métodos de serviço (ex: gráficos) virão aqui.
}