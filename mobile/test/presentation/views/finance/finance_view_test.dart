import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:antibet/src/presentation/views/finance/finance_view.dart';

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
          path: '/finance/simulator', // Rota de destino simulada do simulador
          builder: (context, state) => const Text('Simulator Screen'),
        ),
        GoRoute(
          path: '/finance/openbanking', // Rota de destino simulada do Open Banking
          builder: (context, state) => const Text('Open Banking Screen'),
        ),
      ],
    ).createRouterWidget(context);
  }
}

Widget createWidgetUnderTest() {
  return const MockGoRouterProvider(
    child: FinanceView(),
  );
}

void main() {
  group('FinanceView Widget Tests', () {
    testWidgets('Should display all key financial metrics and titles', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verifica os títulos principais
      expect(find.text('Painel Financeiro'), findsOneWidget);
      expect(find.text('Suas Conquistas Financeiras'), findsOneWidget);

      // Verifica o Card Principal (Economia Acumulada)
      expect(find.text('Seu Saldo AntiBet é de:'), findsOneWidget);
      expect(find.text('R\$ 7.345,50'), findsOneWidget); // Valor simulado

      // Verifica as Métricas de Progresso
      expect(find.text('Dias sem Apostar'), findsOneWidget);
      expect(find.text('Metas Alcançadas'), findsOneWidget);
      expect(find.text('125'), findsOneWidget); // Valor simulado de Dias
      expect(find.text('3'), findsOneWidget); // Valor simulado de Metas
      
      // Verifica o Simulador de Oportunidade Perdida
      expect(find.text('Simulador de Oportunidade Perdida'), findsOneWidget);
      
      // Verifica o CTA de Open Banking
      expect(find.text('Conecte seu banco (Open Banking) para dados em tempo real e mais precisos.'), findsOneWidget);
    });

    testWidgets('Tapping the Opportunity Simulator card should navigate', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Encontra o card do Simulador
      final simulatorCard = find.widgetWithText(ListTile, 'Simulador de Oportunidade Perdida');
      expect(simulatorCard, findsOneWidget);

      // Ação: Tocar no card
      await tester.tap(simulatorCard);
      await tester.pumpAndSettle();

      // Verificação: Deve ter navegado para a rota simulada
      expect(find.text('Simulator Screen'), findsOneWidget);
    });

    testWidgets('Tapping the Open Banking CTA should navigate', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Encontra o botão Conectar
      final connectButton = find.widgetWithText(TextButton, 'Conectar');
      expect(connectButton, findsOneWidget);

      // Ação: Tocar no botão
      await tester.tap(connectButton);
      await tester.pumpAndSettle();

      // Verificação: Deve ter navegado para a rota simulada
      expect(find.text('Open Banking Screen'), findsOneWidget);
    });
  });
}