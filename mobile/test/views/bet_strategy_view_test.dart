import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Importações dos componentes a serem testados e dependências
import 'package:antibet_mobile/core/domain/bet_strategy_model.dart';
import 'package:antibet_mobile/notifiers/bet_strategy_notifier.dart';
import 'package:antibet_mobile/presentation/views/bet_strategy_view.dart';

// Gera o mock para o BetStrategyNotifier
@GenerateMocks([BetStrategyNotifier])
import 'bet_strategy_view_test.mocks.dart'; 

void main() {
  late MockBetStrategyNotifier mockNotifier;

  // Lista de teste
  const List<BetStrategyModel> mockStrategies = [
    BetStrategyModel(
      id: 's1',
      name: 'Martingale Segura',
      description: 'Estratégia de baixo risco.',
      riskFactor: 0.3,
      isActive: true,
    ),
    BetStrategyModel(
      id: 's2',
      name: 'Análise de Gols',
      description: 'Estratégia de alto risco.',
      riskFactor: 0.8,
      isActive: false,
    ),
  ];

  setUp(() {
    mockNotifier = MockBetStrategyNotifier();
    // Garante que o fetchStrategies seja chamado sem falhar (apenas nos testes de erro lidamos com isso)
    when(mockNotifier.fetchStrategies()).thenAnswer((_) async {});
  });

  // Widget Wrapper que simula o ambiente da aplicação (MaterialApp e Provider)
  Widget createStrategyScreen({required BetStrategyNotifier notifier}) {
    return MaterialApp(
      home: ChangeNotifierProvider<BetStrategyNotifier>.value(
        value: notifier,
        child: const BetStrategyView(),
      ),
    );
  }

  group('BetStrategyView Widget Tests', () {

    // --- Teste 1: Chamada de Fetch Inicial ---
    testWidgets('View chama fetchStrategies() na inicialização', (WidgetTester tester) async {
      when(mockNotifier.state).thenReturn(StrategyState.initial);
      
      await tester.pumpWidget(createStrategyScreen(notifier: mockNotifier));
      
      // O fetchStrategies é chamado no initState, que é executado após o primeiro pump
      verify(mockNotifier.fetchStrategies()).called(1);
    });

    // --- Teste 2: Exibição do Estado Loading ---
    testWidgets('Exibe CircularProgressIndicator quando o estado é loading', (WidgetTester tester) async {
      when(mockNotifier.state).thenReturn(StrategyState.loading);
      
      await tester.pumpWidget(createStrategyScreen(notifier: mockNotifier));
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // --- Teste 3: Exibição do Estado Error ---
    testWidgets('Exibe mensagem de erro e botão de recarregar no estado error', (WidgetTester tester) async {
      when(mockNotifier.state).thenReturn(StrategyState.error);
      when(mockNotifier.errorMessage).thenReturn('Serviço de estratégias offline.');

      await tester.pumpWidget(createStrategyScreen(notifier: mockNotifier));
      
      expect(find.textContaining('Erro ao carregar estratégias:'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Recarregar'), findsOneWidget);

      // Toca para tentar novamente
      await tester.tap(find.widgetWithText(ElevatedButton, 'Recarregar'));
      await tester.pump();
      
      verify(mockNotifier.fetchStrategies()).called(2); // Chamado 1 na inicialização, 1 no retry
    });

    // --- Teste 4: Exibição da Lista de Estratégias ---
    testWidgets('Exibe lista de estratégias no estado loaded', (WidgetTester tester) async {
      when(mockNotifier.state).thenReturn(StrategyState.loaded);
      when(mockNotifier.strategies).thenReturn(mockStrategies);

      await tester.pumpWidget(createStrategyScreen(notifier: mockNotifier));

      // Verifica se o título dos itens da lista estão presentes
      expect(find.text('Martingale Segura'), findsOneWidget);
      expect(find.text('Análise de Gols'), findsOneWidget);
      
      // Verifica o ícone de status (um ativo, um inativo)
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsOneWidget);
      
      // Verifica o FloatingActionButton
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
    
    // --- Teste 5: Lista Vazia ---
    testWidgets('Exibe mensagem de lista vazia quando loaded mas sem dados', (WidgetTester tester) async {
      when(mockNotifier.state).thenReturn(StrategyState.loaded);
      when(mockNotifier.strategies).thenReturn([]);

      await tester.pumpWidget(createStrategyScreen(notifier: mockNotifier));

      expect(find.text('Nenhuma estratégia cadastrada.'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Buscar Novamente'), findsOneWidget);
    });
  });
}