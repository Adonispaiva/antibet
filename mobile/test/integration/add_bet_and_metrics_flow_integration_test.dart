import 'package:antibet/core/notifiers/bet_journal_notifier.dart';
import 'package:antibet/core/notifiers/financial_metrics_notifier.dart';
import 'package:antibet/core/services/bet_journal_service.dart';
import 'package:antibet/core/services/financial_metrics_service.dart';
import 'package:antibet/mobile/presentation/screens/journal/add_bet_journal_entry_screen.dart';
import 'package:antibet/mobile/presentation/screens/dashboard/dashboard_screen.dart'; // Tela para verificar o resultado
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Mocks essenciais
class MockBetJournalService extends Mock implements BetJournalService {}
class MockFinancialMetricsService extends Mock implements FinancialMetricsService {}

void main() {
  // Mocks de Serviço (camada de infra)
  MockBetJournalService mockJournalService;
  MockFinancialMetricsService mockMetricsService;

  // Notifiers reais (camada de estado/business logic)
  late BetJournalNotifier betJournalNotifier;
  late FinancialMetricsNotifier financialMetricsNotifier;
  
  // Cria um GoRouter de teste
  late GoRouter router; 

  setUp(() {
    mockJournalService = MockBetJournalService();
    mockMetricsService = MockFinancialMetricsService();

    // Inicializa o BetJournalNotifier (depende do Service mockado)
    betJournalNotifier = BetJournalNotifier(mockJournalService);
    
    // Inicializa o FinancialMetricsNotifier (depende do Service mockado - e será consumidor reativo)
    financialMetricsNotifier = FinancialMetricsNotifier(mockMetricsService);
    
    // Configuração inicial dos mocks de serviço:
    // Retornar lista vazia de entradas no início
    when(mockJournalService.loadEntries()).thenAnswer((_) async => []);
    
    // Configuração do Router de Teste para navegação Add -> Dashboard
    router = GoRouter(
      initialLocation: '/add_bet',
      routes: [
        GoRoute(
          path: '/add_bet',
          builder: (context, state) => const AddBetJournalEntryScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
      ],
    );
    
    // Configura o mock do serviço de Métricas para retornar um valor inicial
    when(mockMetricsService.calculateMetrics(any)).thenAnswer((_) async {
        // Simulação de Recálculo: se não houver entradas, o lucro é 0.0
        return const FinancialMetricsModel(
          totalBalance: 0.0, totalStaked: 0.0, netProfitLoss: 0.0, roiPercentage: 0.0, winRate: 0.0);
    });
  });

  // Helper function para envelopar o widget no ambiente reativo (SSOT Simulation)
  Widget createReactiveFlowTestWidget() {
    return MultiProvider(
      providers: [
        // O Journal Notifier é o "Source of Truth"
        ChangeNotifierProvider<BetJournalNotifier>.value(value: betJournalNotifier),
        
        // O FinancialMetricsNotifier deve ser um ProxyProvider na arquitetura real
        // Para o teste de integração, usamos o ChangeNotifierProxyProvider
        // (Simulando a injeção do main.dart)
        ChangeNotifierProxyProvider<BetJournalNotifier, FinancialMetricsNotifier>(
          create: (_) => financialMetricsNotifier,
          update: (context, journal, metrics) {
            // Este é o ponto crítico de teste: a reatividade
            metrics!.recalculate(journal.entries); 
            return metrics;
          },
        ),
      ],
      child: MaterialApp.router(
        routerDelegate: router.routerDelegate,
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
      ),
    );
  }

  group('Add Bet & Metrics Reactivity Integration Test', () {
    testWidgets('Adding a bet entry triggers metrics recalculation and updates Dashboard', (WidgetTester tester) async {
      // 1. Build the initial widget (AddBetJournalEntryScreen)
      await tester.pumpWidget(createReactiveFlowTestWidget());
      await tester.pumpAndSettle(); // Renders the AddBetJournalEntryScreen

      // Verification: Check if the AddBetJournalEntryScreen is visible
      expect(find.byType(AddBetJournalEntryScreen), findsOneWidget);
      
      // 2. Mock the successful saving of a new entry
      // Quando o Notifier.addEntry for chamado, simule o sucesso do service e atualize o estado interno do Notifier.
      when(mockJournalService.saveEntry(any)).thenAnswer((_) async => true);
      
      // 3. Simulate filling and submitting the form (Aposta de 10.0 com Payout de 20.0 - Lucro de 10.0)
      // Usaremos as chaves de teste definidas no arquivo add_bet_journal_entry_screen_test.dart
      await tester.enterText(find.byKey(const Key('description_field')), 'Aposta Teste Vencedora');
      await tester.enterText(find.byKey(const Key('stake_field')), '10.0');
      // Assume-se que o resultado 'Win' é selecionado e Payout é preenchido como 20.0
      
      // 4. Tap the Save Entry button
      await tester.tap(find.text('Save Entry'));
      await tester.pump(); // Inicia a rebuild e a chamada do Notifier/Service
      
      // Simula a navegação para o Dashboard após o salvamento
      router.go('/dashboard'); 
      await tester.pumpAndSettle(); // Finaliza a navegação e a reatividade

      // 5. Verification: Check if the Dashboard is visible and the metric is updated
      expect(find.byType(DashboardScreen), findsOneWidget);
      
      // O ponto CRÍTICO: Verificar se o FinancialMetricsCard exibe o lucro de R$ 10.00
      // Assume-se que o FinancialMetricsCard renderiza 'Net Profit' e o valor.
      // O recálculo deve ter ocorrido reativamente (Journal -> FinancialMetrics)
      expect(find.text('Net Profit'), findsOneWidget); 
      expect(find.textContaining('R\$ 10.00'), findsOneWidget); 
    });
  });
}