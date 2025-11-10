import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:go_router/go_router.dart';

// Importações dos Notifiers e do Widget
import 'package:antibet/src/core/notifiers/behavioral_analytics_notifier.dart';
import 'package:antibet/src/presentation/widgets/risk_intervention_widget.dart';

// Mocks
class MockBehavioralAnalyticsNotifier extends Mock implements BehavioralAnalyticsNotifier {
  // Simula o estado interno do Notifier
  bool _isHighRisk = false;
  
  @override
  bool get isHighRisk => _isHighRisk;
  
  void setHighRisk(bool value) {
    _isHighRisk = value;
    notifyListeners();
  }

  // Mock para simular o ChangeNotifier
  @override
  void addListener(VoidCallback listener) => super.noSuchMethod(Invocation.method(#addListener, [listener]), returnValue: null);
  @override
  void removeListener(VoidCallback listener) => super.noSuchMethod(Invocation.method(#removeListener, [listener]), returnValue: null);
}

// Helper para o AppRouter (necessário para testar a navegação)
class MockGoRouterProvider extends StatelessWidget {
  const MockGoRouterProvider({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => child),
        GoRoute(path: '/prevention', builder: (context, state) => const Text('Prevention Screen')),
        GoRoute(path: '/lockdown', builder: (context, state) => const Text('Lockdown Screen')),
      ],
    ).createRouterWidget(context);
  }
}

Widget createWidgetUnderTest(MockBehavioralAnalyticsNotifier mockNotifier) {
  return MaterialApp(
    home: MockGoRouterProvider(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<BehavioralAnalyticsNotifier>.value(value: mockNotifier),
        ],
        child: const Scaffold(
          body: RiskInterventionWidget(), // O widget sob teste
        ),
      ),
    ),
  );
}

void main() {
  late MockBehavioralAnalyticsNotifier mockNotifier;

  setUp(() {
    mockNotifier = MockBehavioralAnalyticsNotifier();
  });

  group('RiskInterventionWidget Tests', () {
    testWidgets('Widget should be HIDDEN when isHighRisk is false', (WidgetTester tester) async {
      // Setup: Risco Baixo
      when(mockNotifier.isHighRisk).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest(mockNotifier));
      
      // Verificação: O widget (ou seu conteúdo principal) não deve ser encontrado
      expect(find.byType(RiskInterventionWidget), findsOneWidget); // O widget existe
      expect(find.text('Alerta de Risco Alto'), findsNothing); // O conteúdo não
      expect(find.byType(Card), findsNothing); // A UI visível não
    });

    testWidgets('Widget should be VISIBLE when isHighRisk is true', (WidgetTester tester) async {
      // Setup: Risco Alto
      when(mockNotifier.isHighRisk).thenReturn(true);
      
      await tester.pumpWidget(createWidgetUnderTest(mockNotifier));

      // Verificação: O conteúdo visível deve aparecer
      expect(find.text('Alerta de Risco Alto'), findsOneWidget);
      expect(find.textContaining('Percebemos um aumento nos seus padrões de risco.'), findsOneWidget);
      expect(find.text('Ver Ferramentas'), findsOneWidget);
      expect(find.text('Ativar Pânico'), findsOneWidget);
    });

    testWidgets('Tapping "Ver Ferramentas" should navigate to /prevention', (WidgetTester tester) async {
      // Setup: Risco Alto
      when(mockNotifier.isHighRisk).thenReturn(true);
      
      await tester.pumpWidget(createWidgetUnderTest(mockNotifier));

      final preventionButton = find.text('Ver Ferramentas');
      expect(preventionButton, findsOneWidget);

      // Ação: Tocar no botão
      await tester.tap(preventionButton);
      await tester.pumpAndSettle();

      // Verificação: Deve navegar para a tela simulada
      expect(find.text('Prevention Screen'), findsOneWidget);
    });

    testWidgets('Tapping "Ativar Pânico" should navigate to /lockdown', (WidgetTester tester) async {
      // Setup: Risco Alto
      when(mockNotifier.isHighRisk).thenReturn(true);
      
      await tester.pumpWidget(createWidgetUnderTest(mockNotifier));

      final lockdownButton = find.text('Ativar Pânico');
      expect(lockdownButton, findsOneWidget);

      // Ação: Tocar no botão
      await tester.tap(lockdownButton);
      await tester.pumpAndSettle();

      // Verificação: Deve navegar para a tela simulada
      expect(find.text('Lockdown Screen'), findsOneWidget);
    });
  });
}