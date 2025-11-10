import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:go_router/go_router.dart';

import 'package:antibet/src/core/notifiers/dashboard_notifier.dart';
import 'package:antibet/src/core/services/dashboard_service.dart';
import 'package:antibet/src/presentation/views/dashboard/progress_view.dart';

// Mocks
class MockDashboardNotifier extends Mock implements DashboardNotifier {
  @override
  List<Goal> get userGoals => super.noSuchMethod(
        Invocation.getter(#userGoals),
        returnValue: [
          Goal(id: 'g1', title: 'Meta Pendente', isCompleted: false),
          Goal(id: 'g2', title: 'Meta Concluída', isCompleted: true),
        ],
      ) as List<Goal>;

  @override
  bool get isLoading => super.noSuchMethod(
        Invocation.getter(#isLoading),
        returnValue: false,
      ) as bool;

  @override
  Future<void> completeGoal(String goalId) => super.noSuchMethod(
        Invocation.method(#completeGoal, [goalId]),
        returnValue: Future.value(null),
      ) as Future<void>;

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
        GoRoute(path: '/dashboard/add-goal', builder: (context, state) => const Text('Add Goal Screen')),
      ],
    ).createRouterWidget(context);
  }
}

Widget createWidgetUnderTest(MockDashboardNotifier mockNotifier) {
  return MaterialApp(
    home: MockGoRouterProvider(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<DashboardNotifier>.value(value: mockNotifier),
        ],
        child: const ProgressView(),
      ),
    ),
  );
}

void main() {
  late MockDashboardNotifier mockNotifier;

  setUp(() {
    mockNotifier = MockDashboardNotifier();
    // Garante que o estado inicial do mock será usado
    when(mockNotifier.userGoals).thenReturn([
      Goal(id: 'g1', title: 'Meta Pendente', isCompleted: false),
      Goal(id: 'g2', title: 'Meta Concluída', isCompleted: true),
      Goal(id: 'g3', title: 'Outra Meta', isCompleted: false),
    ]);
  });

  group('ProgressView Widget Tests', () {
    testWidgets('Should display the Days Counter and correct goal counts', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(mockNotifier));
      await tester.pumpAndSettle();

      // 1. Verifica o Título e Contador de Dias (Métrica Chave)
      expect(find.text('Meu Progresso'), findsOneWidget);
      expect(find.text('Suas Vitórias'), findsOneWidget);
      expect(find.textContaining('125'), findsOneWidget); // Valor simulado
      
      // 2. Verifica o contador de Metas (1/3 concluídas no mock, mas a UI mostra 2/3)
      // O mock tem 3 metas, 1 concluída, 2 pendentes. Total: 3. Concluídas: 1.
      // O mock retorna: [f, t, f]. Concluídas: 1. Total: 3.
      // A UI calcula: 1 concluída / 3 total.
      expect(find.text('Metas Pessoais (1/3)'), findsOneWidget); 

      // 3. Verifica a listagem das metas
      expect(find.text('Meta Pendente'), findsOneWidget);
      expect(find.text('Meta Concluída'), findsOneWidget);
      expect(find.text('Outra Meta'), findsOneWidget);
    });

    testWidgets('Tapping the star icon should complete the goal and show snackbar', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(mockNotifier));
      await tester.pumpAndSettle();

      // 1. Encontra a meta pendente (Meta Pendente)
      final pendingGoalTile = find.widgetWithText(ListTile, 'Meta Pendente');
      
      // 2. Encontra o botão de Estrela (Apenas metas pendentes têm o trailing)
      final starButton = find.descendant(of: pendingGoalTile, matching: find.byIcon(Icons.star));
      expect(starButton, findsOneWidget);

      // 3. Ação: Toca no botão
      await tester.tap(starButton);
      await tester.pump();
      
      // Verificação 1: O método crítico completeGoal deve ser chamado
      verify(mockNotifier.completeGoal('g1')).called(1);
      
      // Verificação 2: Deve mostrar o SnackBar de reforço positivo
      expect(find.text('Meta concluída! Parabéns pela sua força!'), findsOneWidget);
      
      // Observação: Não podemos verificar a linha riscada aqui, pois o mock retorna o estado inicial, 
      // mas a chamada ao notifier é o objetivo principal do teste.
    });
    
    testWidgets('Tapping the add goal button should navigate to the add goal screen', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(mockNotifier));
      await tester.pumpAndSettle();
      
      // 1. Encontra o botão de adição de metas (ícone de add_circle_outline)
      final addButton = find.byTooltip('Adicionar nova meta');
      expect(addButton, findsOneWidget);
      
      // 2. Ação: Toca no botão
      await tester.tap(addButton);
      await tester.pumpAndSettle();
      
      // Verificação: Deve navegar para a rota simulada
      expect(find.text('Add Goal Screen'), findsOneWidget);
    });

    testWidgets('Should display loading indicator when data is loading', (WidgetTester tester) async {
      // Setup: Mocka o estado de isLoading para true
      when(mockNotifier.isLoading).thenReturn(true);
      
      await tester.pumpWidget(createWidgetUnderTest(mockNotifier));
      
      // Verifica o indicador de carregamento
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // O texto das metas não deve aparecer
      expect(find.text('Meta Pendente'), findsNothing);
    });
  });
}