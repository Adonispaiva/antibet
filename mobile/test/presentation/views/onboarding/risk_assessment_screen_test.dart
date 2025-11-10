import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:antibet/src/presentation/views/onboarding/risk_assessment_screen.dart';

// Helper para o AppRouter (necessário para testar context.go('/home'))
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
          path: '/home', // Rota de destino após a conclusão
          builder: (context, state) => const Text('Home Screen'),
        ),
      ],
    ).createRouterWidget(context);
  }
}

Widget createWidgetUnderTest() {
  return const MockGoRouterProvider(
    child: RiskAssessmentScreen(),
  );
}

// Funções utilitárias para interação nos testes
Finder findLikertOption(int value) => find.widgetWithText(RadioListTile, _getLikertLabel(value));
String _getLikertLabel(int value) {
  switch (value) {
    case 0: return 'Nunca ou Quase Nunca';
    case 1: return 'Raramente';
    case 2: return 'Às Vezes';
    case 3: return 'Frequentemente';
    case 4: return 'Quase Sempre ou Sempre';
    default: return '';
  }
}

Future<void> answerQuestion(WidgetTester tester, int answerValue) async {
  await tester.tap(findLikertOption(answerValue));
  await tester.pump();
  await tester.tap(find.widgetWithText(ElevatedButton, 'Próxima'));
  await tester.pumpAndSettle();
}

void main() {
  group('RiskAssessmentScreen Widget Tests', () {
    testWidgets('Should navigate through all steps and show the result screen', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // 1. Início: Verifica o título e o progresso inicial
      expect(find.text('Pergunta 1 de 5'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Anterior'), findsNothing); // Botão "Anterior" desabilitado

      // 2. Responder 4 perguntas (Exemplo: 4, 3, 2, 1)
      await answerQuestion(tester, 4); // Vai para Pergunta 2
      expect(find.text('Pergunta 2 de 5'), findsOneWidget);

      await answerQuestion(tester, 3); // Vai para Pergunta 3
      expect(find.text('Pergunta 3 de 5'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Anterior'), findsOneWidget); // Botão "Anterior" habilitado

      await answerQuestion(tester, 2); // Vai para Pergunta 4
      expect(find.text('Pergunta 4 de 5'), findsOneWidget);

      await answerQuestion(tester, 1); // Vai para Pergunta 5
      expect(find.text('Pergunta 5 de 5'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Próxima'), findsOneWidget); // Ainda é "Próxima"

      // 3. Responde a última pergunta e Finaliza (Total Score: 4+3+2+1+0 = 10)
      await tester.tap(findLikertOption(0));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Finalizar')); // Botão muda para "Finalizar"
      await tester.pumpAndSettle(); // Espera o setState e a transição

      // 4. Verifica a Tela de Resultado
      expect(find.text('Resultado da Avaliação'), findsOneWidget);
      expect(find.text('Moderado'), findsOneWidget); // Score 10 cai em 'Moderado' (5 < 10 <= 12)
      expect(find.text('Continuar para plano de apoio'), findsOneWidget);

      // 5. Teste de navegação final
      await tester.tap(find.text('Continuar para plano de apoio'));
      await tester.pumpAndSettle();
      expect(find.text('Home Screen'), findsOneWidget);
    });

    testWidgets('Should correctly calculate and display HIGH Risk (Score 20)', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Responde 5 vezes com a pontuação máxima (4)
      for (int i = 0; i < 4; i++) {
        await answerQuestion(tester, 4);
      }
      
      // Resposta final e Finalizar
      await tester.tap(findLikertOption(4));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Finalizar')); 
      await tester.pumpAndSettle();

      // Verifica Risco Alto (Score total 20 > 12)
      expect(find.text('Alto'), findsOneWidget);
      expect(find.text('Baixo'), findsNothing);
      expect(find.text('Moderado'), findsNothing);
    });
    
    testWidgets('Should correctly calculate and display LOW Risk (Score 0)', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Responde 5 vezes com a pontuação mínima (0)
      for (int i = 0; i < 4; i++) {
        await answerQuestion(tester, 0);
      }
      
      // Resposta final e Finalizar
      await tester.tap(findLikertOption(0));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Finalizar')); 
      await tester.pumpAndSettle();

      // Verifica Risco Baixo (Score total 0 <= 5)
      expect(find.text('Baixo'), findsOneWidget);
      expect(find.text('Alto'), findsNothing);
      expect(find.text('Moderado'), findsNothing);
    });
  });
}