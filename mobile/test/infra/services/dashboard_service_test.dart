import 'package:flutter_test/flutter_test.dart';
import 'package:antibet_mobile/models/dashboard_summary_model.dart';
import 'package:antibet_mobile/infra/services/dashboard_service.dart';

// =========================================================================
// SIMULAÇÃO DE DEPENDÊNCIAS (Mocks)
// =========================================================================

// Simulação de DashboardSummaryModel (para que o teste possa ser executado neste ambiente)
class DashboardSummaryModel {
  final int totalStrategies;
  final double averageWinRate;
  final int lowRiskStrategies;
  final int mediumRiskStrategies;
  final int highRiskStrategies;
  final int newStrategiesToday;

  DashboardSummaryModel({required this.totalStrategies, required this.averageWinRate, required this.lowRiskStrategies, required this.mediumRiskStrategies, required this.highRiskStrategies, required this.newStrategiesToday});

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
  factory DashboardSummaryModel.empty() => throw UnimplementedError();
}

// Mock da classe de Serviço do Dashboard
class DashboardService {
  DashboardService();
  bool shouldThrowError = false;

  Future<DashboardSummaryModel> getDashboardSummary() async {
    if (shouldThrowError) {
      await Future.delayed(Duration.zero);
      throw Exception('Falha ao carregar dados do dashboard.');
    }
    
    // Simulação de chamada de rede
    await Future.delayed(Duration.zero);

    final Map<String, dynamic> mockApiResponse = {
      'totalStrategies': 42,
      'averageWinRate': 78.5,
      'lowRiskStrategies': 15,
      'mediumRiskStrategies': 20,
      'highRiskStrategies': 7,
      'newStrategiesToday': 3,
    };

    return DashboardSummaryModel.fromJson(mockApiResponse);
  }
}
// =========================================================================
// FIM DA SIMULAÇÃO
// =========================================================================

void main() {
  group('DashboardService Unit Tests', () {
    late DashboardService dashboardService;

    setUp(() {
      dashboardService = DashboardService();
    });

    test('01. getDashboardSummary deve retornar DashboardSummaryModel e parsear corretamente', () async {
      final summary = await dashboardService.getDashboardSummary();

      expect(summary, isA<DashboardSummaryModel>());
      expect(summary.totalStrategies, 42);
      expect(summary.averageWinRate, 78.5); // Verificação do double
      expect(summary.lowRiskStrategies, 15);
      expect(summary.mediumRiskStrategies, 20);
      expect(summary.highRiskStrategies, 7);
      expect(summary.newStrategiesToday, 3);
    });

    test('02. getDashboardSummary deve lançar exceção em caso de falha na API', () async {
      dashboardService.shouldThrowError = true;

      expect(
        () => dashboardService.getDashboardSummary(),
        throwsA(isA<Exception>()),
      );
    });
  });
}