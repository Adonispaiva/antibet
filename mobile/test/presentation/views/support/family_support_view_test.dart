import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:antibet/src/presentation/views/support/family_support_view.dart';

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
          path: '/support/guidance', // Rota de destino simulada da orientação
          builder: (context, state) => const Text('Guidance Detail'),
        ),
        GoRoute(
          path: '/community', // Rota de destino simulada da comunidade
          builder: (context, state) => const Text('Community Screen'),
        ),
        GoRoute(
          path: '/support/phrases', // Rota de destino simulada das frases
          builder: (context, state) => const Text('Phrases Screen'),
        ),
      ],
    ).createRouterWidget(context);
  }
}

Widget createWidgetUnderTest() {
  return const MockGoRouterProvider(
    child: FamilySupportView(),
  );
}

void main() {
  group('FamilySupportView Widget Tests', () {
    testWidgets('Should display all key guidance cards and resource links', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verifica os títulos e introdução
      expect(find.text('Área de Apoio à Família'), findsOneWidget);
      expect(find.text('Apoio para Quem Ajuda'), findsOneWidget);

      // Verifica os Cards de Orientação Principal
      expect(find.text('Como Ajudar Alguém'), findsOneWidget);
      expect(find.text('Ferramentas de Conversa'), findsOneWidget);

      // Verifica os Links de Recursos Profissionais e Comunitários
      expect(find.text('Suporte Profissional e Comunitário'), findsOneWidget);
      expect(find.text('Comunidade de Apoio'), findsOneWidget);
      expect(find.text('Aconselhamento Profissional'), findsOneWidget);
    });

    testWidgets('Tapping "Como Ajudar Alguém" card should navigate', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Encontra o card de orientação
      final guidanceCard = find.widgetWithText(ListTile, 'Como Ajudar Alguém');
      expect(guidanceCard, findsOneWidget);

      // Ação: Tocar no card
      await tester.tap(guidanceCard);
      await tester.pumpAndSettle();

      // Verificação: Deve ter navegado para a rota simulada
      expect(find.text('Guidance Detail'), findsOneWidget);
    });

    testWidgets('Tapping "Comunidade de Apoio" resource should navigate', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Encontra o link da Comunidade
      final communityLink = find.widgetWithText(ListTile, 'Comunidade de Apoio');
      expect(communityLink, findsOneWidget);

      // Ação: Tocar no link
      await tester.tap(communityLink);
      await tester.pumpAndSettle();

      // Verificação: Deve ter navegado para a rota simulada
      expect(find.text('Community Screen'), findsOneWidget);
    });
  });
}