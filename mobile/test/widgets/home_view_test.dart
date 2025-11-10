import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:go_router/go_router.dart';

import 'package:antibet/src/core/notifiers/lockdown_notifier.dart';
import 'package:antibet/src/core/notifiers/behavioral_analytics_notifier.dart';
import 'package:antibet/src/presentation/views/home/home_view.dart';
import 'package:antibet/src/widgets/risk_intervention_widget.dart';

// Mocks
class MockLockdownNotifier extends Mock implements LockdownNotifier {
  @override
  Future<void> activateLockdown() => super.noSuchMethod(
        Invocation.method(#activateLockdown, []),
        returnValue: Future.value(null),
      ) as Future<void>;
  
  // Mock para GoRouter, necessário pois o Notifier é um RefreshListenable
  @override
  void addListener(VoidCallback listener) => super.noSuchMethod(Invocation.method(#addListener, [listener]), returnValue: null);
  @override
  void removeListener(VoidCallback listener) => super.noSuchMethod(Invocation.method(#removeListener, [listener]), returnValue: null);
}

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
  
  // Mock para simular o ChangeNotifier
  @override
  void addListener(VoidCallback listener) => super.noSuchMethod(Invocation.method(#addListener, [listener]), returnValue: null);
  @override
  void removeListener(VoidCallback listener) => super.noSuchMethod(Invocation.method(#removeListener, [listener]), returnValue: null);
}

// Helper para o AppRouter (necessário para testar navegação com context.go)
class MockGoRouterProvider extends StatelessWidget {
  const MockGoRouterProvider({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => child,
        ),
        GoRoute(
          path: '/lockdown', // Rota de redirecionamento do SOS
          builder: (context, state) => const Text('Lockdown Screen'),
        ),
        GoRoute(
          path: '/chat',
          builder: (context, state) => const Text('Chat Screen'),
        ),
      ],
    ).createRouterWidget(context);
  }
}

Widget createWidgetUnderTest(MockLockdownNotifier mockLockdown, MockBehavioralAnalyticsNotifier mockAnalytics) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<LockdownNotifier>.value(value: mockLockdown),
      ChangeNotifierProvider<BehavioralAnalyticsNotifier>.value(value: mockAnalytics),
    ],
    child: MockGoRouterProvider(
      child: const HomeView(),
    ),
  );
}

void main() {
  late MockLockdownNotifier mockLockdown;
  late MockBehavioralAnalyticsNotifier mockAnalytics;

  setUp(() {
    mockLockdown = MockLockdownNotifier();
    mockAnalytics = MockBehavioralAnalyticsNotifier();
  });

  group('HomeView Widget Tests', () {
    testWidgets('Should display risk score correctly in AppBar (Low Risk)', (WidgetTester tester) async {
      // Setup Risco Baixo
      when(mockAnalytics.riskScore).thenReturn(0.45);
      when(mockAnalytics.isHighRisk).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest(mockLockdown, mockAnalytics));

      // Verifica o texto do score
      expect(find.text('Risco: 0.45'), findsOneWidget);
      // O RiskInterventionWidget não deve estar presente
      expect(find.byType(RiskInterventionWidget), findsNothing); 
    });

    testWidgets('Should display RiskInterventionWidget when risk is HIGH', (WidgetTester tester) async {
      // Setup Risco Alto
      when(mockAnalytics.riskScore).thenReturn(0.85);
      when(mockAnalytics.isHighRisk).thenReturn(true);

      await tester.pumpWidget(createWidgetUnderTest(mockLockdown, mockAnalytics));
      await tester.pumpAndSettle();

      // Verifica o texto do score
      expect(find.text('Risco: 0.85'), findsOneWidget);
      // O RiskInterventionWidget DEVE estar presente (embora a lógica interna dele não seja testada aqui)
      expect(find.byType(RiskInterventionWidget), findsOneWidget); 
    });

    testWidgets('Tapping Emergency Button (SOS) should activate lockdown and navigate', (WidgetTester tester) async {
      // Setup Risco Baixo para isolar o teste do SOS
      when(mockAnalytics.riskScore).thenReturn(0.1);

      await tester.pumpWidget(createWidgetUnderTest(mockLockdown, mockAnalytics));
      await tester.pumpAndSettle();

      final sosButton = find.text('Botão de Emergência (SOS)');
      expect(sosButton, findsOneWidget);

      // Ação: Tocar no botão
      await tester.tap(sosButton);
      await tester.pumpAndSettle(); // Espera a navegação e a ativação

      // Verificação 1: O método crítico do Notifier deve ser chamado
      verify(mockLockdown.activateLockdown()).called(1);
      
      // Verificação 2: A navegação deve ter ocorrido
      expect(find.text('Lockdown Screen'), findsOneWidget);
    });

    testWidgets('Tapping Chat Card should navigate to /chat', (WidgetTester tester) async {
      // Setup padrão
      when(mockAnalytics.riskScore).thenReturn(0.1);
      
      await tester.pumpWidget(createWidgetUnderTest(mockLockdown, mockAnalytics));
      await tester.pumpAndSettle();
      
      final chatCard = find.text('Reflexões AntiBet');
      expect(chatCard, findsOneWidget);
      
      // Ação: Tocar no card
      await tester.tap(chatCard);
      await tester.pumpAndSettle();

      // Verificação: A navegação deve ter ocorrido
      expect(find.text('Chat Screen'), findsOneWidget);
    });
  });
}