import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:antibet/src/presentation/views/anti_addiction/prevention_view.dart';

// Helper para o AppRouter (necessário para testar context.go)
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
          path: '/settings/autoblock', // Rota de destino simulada para o bloqueio
          builder: (context, state) => const Text('Autoblock Settings'),
        ),
      ],
    ).createRouterWidget(context);
  }
}

Widget createWidgetUnderTest() {
  return const MockGoRouterProvider(
    child: PreventionView(),
  );
}

void main() {
  group('PreventionView Widget Tests', () {
    testWidgets('Should display all key prevention elements and emergency contacts', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verifica o título principal
      expect(find.text('Ferramentas de Prevenção'), findsOneWidget);
      expect(find.text('Assuma o Controle'), findsOneWidget);

      // Verifica o Contador de Tempo (simulado)
      expect(find.text('Dias de Força'), findsOneWidget);
      expect(find.text('125'), findsOneWidget); // O valor simulado

      // Verifica as Ferramentas de Autocontrole
      expect(find.text('Bloqueio e Autoexclusão'), findsOneWidget);
      expect(find.text('Delay Timer e Metas'), findsOneWidget);

      // Verifica os Títulos e Links de Ajuda Profissional
      expect(find.text('Ajuda Profissional e Emergência'), findsOneWidget);
      expect(find.text('Ligue CVV (Centro de Valorização da Vida)'), findsOneWidget);
      expect(find.text('Recursos CAPS AD'), findsOneWidget);
    });

    testWidgets('Tapping the Bloqueio e Autoexclusão card should navigate', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Encontra o card de Bloqueio
      final autoBlockCard = find.widgetWithText(ListTile, 'Bloqueio e Autoexclusão');
      expect(autoBlockCard, findsOneWidget);

      // Ação: Tocar no card
      await tester.tap(autoBlockCard);
      await tester.pumpAndSettle();

      // Verificação: Deve ter navegado para a rota simulada
      expect(find.text('Autoblock Settings'), findsOneWidget);
    });

    testWidgets('Tapping Emergency Contact buttons should register a tap event', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Encontra os botões de Ajuda Profissional
      final cvvButton = find.widgetWithText(ElevatedButton, 'Ligue CVV (Centro de Valorização da Vida)');
      final capsButton = find.widgetWithText(ElevatedButton, 'Recursos CAPS AD');
      
      expect(cvvButton, findsOneWidget);
      expect(capsButton, findsOneWidget);
      
      // Ação: Toca nos botões (Simula que a função onTap é chamada, embora não possa testar o lançamento de URL/chamada telefônica)
      await tester.tap(cvvButton);
      await tester.pump();
      
      await tester.tap(capsButton);
      await tester.pump();
      
      // O teste passa se os botões forem encontrados e puderem ser pressionados sem erro
    });
  });
}