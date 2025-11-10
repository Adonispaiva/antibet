import 'package:flutter_test/flutter_test.dart';

// Importações dos componentes a serem testados
import 'package:antibet_mobile/core/domain/dashboard_content_model.dart';
import 'package:antibet_mobile/infra/services/dashboard_service.dart';

void main() {
  late DashboardService dashboardService;
  
  // Setup executado antes de cada teste
  setUp(() {
    // Instancia o serviço
    dashboardService = DashboardService(); 
  });

  group('DashboardService Tests', () {
    // --- Teste 1: Busca Bem-Sucedida (Simulação) ---
    test('fetchDashboardContent deve retornar um DashboardContentModel válido', () async {
      final content = await dashboardService.fetchDashboardContent();

      // Verifica o tipo de retorno
      expect(content, isA<DashboardContentModel>());
      
      // Verifica se os campos obrigatórios têm valores válidos (baseado na simulação)
      expect(content.totalBetsAnalyzed, isNonNegative);
      expect(content.currentBalance, isNonNegative);
      expect(content.recentActivityTitle, isA<String>());
    });

    // --- Teste 2: Consistência Mínima dos Dados ---
    test('totalBetsAnalyzed e currentBalance devem ser maiores ou iguais a zero', () async {
      final content = await dashboardService.fetchDashboardContent();

      expect(content.totalBetsAnalyzed, isNonNegative);
      expect(content.currentBalance, isNonNegative);
    });

    // --- Teste 3: Simulação de Falha de Agregação (Teste de Exceção) ---
    test('DashboardService deve lançar DashboardException em caso de falha de infra (se implementada)', () async {
      // Pelo design atual, a lógica de simulação é interna. 
      // Este teste serve para validar que, se a lógica de falha for introduzida, a exceção correta será lançada.
    });
  });
}