import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:antibet/src/core/notifiers/behavioral_analytics_notifier.dart';
import 'package:antibet/src/widgets/risk_intervention_widget.dart';

// Mocks
class MockBehavioralAnalyticsNotifier extends Mock implements BehavioralAnalyticsNotifier {
  @override
  double get riskScore => super.noSuchMethod(
        Invocation.getter(#riskScore),
        returnValue: 0.0,
      ) as double;

  @override
  bool get isHighRisk => super.noSuchMethod(
        Invocation.getter(#isHighRisk),
        returnValue: false,
      ) as bool;
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockBehavioralAnalyticsNotifier mockNotifier;
  late MockNavigatorObserver mockObserver;

  setUp(() {
    mockNotifier = MockBehavioralAnalyticsNotifier();
    mockObserver = MockNavigatorObserver();
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BehavioralAnalyticsNotifier>.value(
          value: mockNotifier,
        ),
      ],
      child: MaterialApp(
        home: const Scaffold(
          body: RiskInterventionWidget(),
        ),
        // Adiciona um NavigatorObserver mock para testar a navegação
        navigatorObservers: [mockObserver],
        // Mapeamento de rotas simples para simular navegação
        routes: {
          '/prevention': (context) => const Text('PreventionView'),
          '/lockdown': (context) => const Text('LockdownView'),
        },
      ),
    );
  }

  group('RiskInterventionWidget Tests', () {
    testWidgets('Widget should NOT appear when risk is LOW', (WidgetTester tester) async {
      // Setup: Risco Baixo
      when(mockNotifier.isHighRisk).thenReturn(false);
      when(mockNotifier.riskScore).thenReturn(0.5); // < 0.7

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verificação: O widget não deve ser encontrado
      expect(find.byType(Card), findsNothing);
      expect(find.text('ALERTA DE RISCO ELEVADO'), findsNothing);
    });

    testWidgets('Widget should appear when risk is HIGH', (WidgetTester tester) async {
      // Setup: Risco Alto
      when(mockNotifier.isHighRisk).thenReturn(true);
      when(mockNotifier.riskScore).thenReturn(0.8); // >= 0.7

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verificação: O widget deve ser encontrado
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('ALERTA DE RISCO ELEVADO'), findsOneWidget);
      expect(find.text('Seu Escore de Risco é 0.8'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNWidgets(2));
    });

    testWidgets('Tapping "Acessar Prevenção" navigates to /prevention', (WidgetTester tester) async {
      // Setup: Risco Alto
      when(mockNotifier.isHighRisk).thenReturn(true);
      when(mockNotifier.riskScore).thenReturn(0.9);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Ação: Tocar no botão de Prevenção
      final preventionButton = find.text('Acessar Prevenção');
      expect(preventionButton, findsOneWidget);
      await tester.tap(preventionButton);
      await tester.pumpAndSettle();

      // Verificação: Deve ter navegado para a rota '/prevention'
      expect(find.text('PreventionView'), findsOneWidget);
      
      // Verificação do MockNavigatorObserver (chamada pushNamed)
      verify(mockObserver.didPush(any, any)).called(1);
    });

    testWidgets('Tapping "Botão de Pânico" navigates to /lockdown', (WidgetTester tester) async {
      // Setup: Risco Alto
      when(mockNotifier.isHighRisk).thenReturn(true);
      when(mockNotifier.riskScore).thenReturn(0.95);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Ação: Tocar no Botão de Pânico
      final lockdownButton = find.text('Botão de Pânico');
      expect(lockdownButton, findsOneWidget);
      await tester.tap(lockdownButton);
      await tester.pumpAndSettle();

      // Verificação: Deve ter navegado para a rota '/lockdown'
      expect(find.text('LockdownView'), findsOneWidget);

      // Verificação do MockNavigatorObserver (chamada pushNamed)
      verify(mockObserver.didPush(any, any)).called(1);
    });
  });
}