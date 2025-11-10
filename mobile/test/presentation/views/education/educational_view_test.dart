import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:antibet/src/presentation/views/education/educational_view.dart';

// Helper para o AppRouter (necessário para testar context.go)
class MockGoRouterProvider extends StatelessWidget {
  const MockGoRouterProvider({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Configura um GoRouter com rotas de destino simuladas
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => child,
        ),
        GoRoute(
          path: '/education/neuroscience', // Rota de destino simulada de um tópico
          builder: (context, state) => const Text('Neuroscience Detail'),
        ),
        GoRoute(
          path: '/education/quiz', // Rota de destino simulada do Quiz
          builder: (context, state) => const Text('Quiz Screen'),
        ),
      ],
    ).createRouterWidget(context);
  }
}

Widget createWidgetUnderTest() {
  return const MockGoRouterProvider(
    child: EducationalView(),
  );
}

void main() {
  group('EducationalView Widget Tests', () {
    testWidgets('Should display all four educational topics and the quiz card', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verifica o título principal
      expect(find.text('Módulo Educacional'), findsOneWidget);
      expect(find.text('Aprenda para Vencer'), findsOneWidget);

      // Verifica a presença dos 4 tópicos principais
      expect(find.text('Neurociência do Vício'), findsOneWidget);
      expect(find.text('RNG, RTP e o Mito do Ganho'), findsOneWidget);
      expect(find.text('A Indústria por Trás do Jogo'), findsOneWidget);
      expect(find.text('Estratégias de Saída (TCC/MI)'), findsOneWidget);
      
      // Verifica a presença do Card de Quiz
      expect(find.text('Quizzes Interativos: Você conhece os riscos?'), findsOneWidget);
    });

    testWidgets('Tapping an educational topic card should navigate to its detail route', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Encontra o tópico de Neurociência
      final neuroscienceCard = find.widgetWithText(ListTile, 'Neurociência do Vício');
      expect(neuroscienceCard, findsOneWidget);

      // Ação: Tocar no card
      await tester.tap(neuroscienceCard);
      await tester.pumpAndSettle();

      // Verificação: Deve ter navegado para a rota simulada
      expect(find.text('Neuroscience Detail'), findsOneWidget);
    });

    testWidgets('Tapping the Quiz button should navigate to the quiz screen', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Encontra o botão Iniciar do Quiz
      final quizButton = find.widgetWithText(ElevatedButton, 'Iniciar');
      expect(quizButton, findsOneWidget);

      // Ação: Tocar no botão
      await tester.tap(quizButton);
      await tester.pumpAndSettle();

      // Verificação: Deve ter navegado para a rota simulada
      expect(find.text('Quiz Screen'), findsOneWidget);
    });
  });
}