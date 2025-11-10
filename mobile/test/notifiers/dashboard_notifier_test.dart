import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Importações dos componentes a serem testados e dependências
import 'package:antibet_mobile/core/domain/dashboard_content_model.dart';
import 'package:antibet_mobile/infra/services/dashboard_service.dart';
import 'package:antibet_mobile/notifiers/dashboard_notifier.dart';

// Gera o mock para a dependência
@GenerateMocks([DashboardService])
import 'dashboard_notifier_test.mocks.dart'; 

void main() {
  late MockDashboardService mockDashboardService;
  late DashboardNotifier dashboardNotifier;

  const DashboardContentModel testContent = DashboardContentModel(
    totalBetsAnalyzed: 1000,
    recentActivityTitle: 'Análise de alta performance concluída.',
    currentBalance: 500.50,
  );
  const DashboardException dashboardError = DashboardException('Falha de agregação de dados.');

  // Configuração executada antes de cada teste
  setUp(() {
    mockDashboardService = MockDashboardService();
    // Injeta o mock
    dashboardNotifier = DashboardNotifier(mockDashboardService); 
  });

  // Limpeza executada após cada teste
  tearDown(() {
    reset(mockDashboardService);
  });

  group('DashboardNotifier Tests', () {
    // --- Teste 1: Estado Inicial ---
    test('Estado inicial é DashboardState.initial e content é nulo', () {
      expect(dashboardNotifier.state, DashboardState.initial);
      expect(dashboardNotifier.content, isNull);
    });

    // --- Teste 2: Busca Bem-Sucedida ---
    test('fetchDashboardContent: sucesso define content e muda para DashboardState.loaded', () async {
      // Configuração: Serviço retorna um modelo de conteúdo
      when(mockDashboardService.fetchDashboardContent()).thenAnswer((_) async => testContent);
      
      await dashboardNotifier.fetchDashboardContent();

      // Verifica as transições de estado
      expect(dashboardNotifier.state, DashboardState.loaded);
      expect(dashboardNotifier.content, testContent);
      expect(dashboardNotifier.content!.totalBetsAnalyzed, 1000);
      
      verify(mockDashboardService.fetchDashboardContent()).called(1);
    });

    // --- Teste 3: Busca Mal-Sucedida (DashboardException) ---
    test('fetchDashboardContent: falha define erro e muda para DashboardState.error', () async {
      // Configuração: Serviço lança exceção
      when(mockDashboardService.fetchDashboardContent()).thenThrow(dashboardError);
      
      await dashboardNotifier.fetchDashboardContent();

      // Verifica o estado final
      expect(dashboardNotifier.state, DashboardState.error);
      expect(dashboardNotifier.content, isNull);
      expect(dashboardNotifier.errorMessage, contains('Falha ao carregar o Dashboard'));
      
      verify(mockDashboardService.fetchDashboardContent()).called(1);
    });
    
    // --- Teste 4: Transições de Estado Corretas (Initial -> Loading -> Loaded) ---
    test('fetchDashboardContent deve notificar listeners na ordem correta', () async {
      when(mockDashboardService.fetchDashboardContent()).thenAnswer((_) async {
        // Simula o delay de rede
        await Future.delayed(const Duration(milliseconds: 10)); 
        return testContent;
      });
      
      final states = <DashboardState>[];
      dashboardNotifier.addListener(() {
        states.add(dashboardNotifier.state);
      });

      await dashboardNotifier.fetchDashboardContent();

      // Esperado: [loading, loaded]
      expect(states, [DashboardState.loading, DashboardState.loaded]);
      expect(dashboardNotifier.state, DashboardState.loaded);
    });
  });
}