import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:antibet/src/presentation/views/onboarding/consent_screen.dart';

// Constante para a chave de consentimento (duplicada para o teste)
const String _consentKey = 'user_accepted_consent';

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
          path: '/register', // Rota de destino após o aceite
          builder: (context, state) => const Text('Register Screen'),
        ),
      ],
    ).createRouterWidget(context);
  }
}

Widget createWidgetUnderTest() {
  return const MockGoRouterProvider(
    child: ConsentScreen(),
  );
}

void main() {
  // Configura o SharedPreferences mock antes de cada teste
  setUp(() {
    // Configura SharedPreferences para simular um ambiente limpo (sem consentimento)
    SharedPreferences.setMockInitialValues({}); 
  });

  testWidgets('ConsentScreen should display text and navigate upon acceptance', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // 1. Verifica o texto de esclarecimento
    expect(find.textContaining('Este app é movido por Inteligência Artificial'), findsOneWidget);
    expect(find.textContaining('Não substitui tratamento psicológico ou médico'), findsOneWidget);

    // 2. Verifica o botão de aceite
    final acceptButton = find.text('Li e aceito');
    expect(acceptButton, findsOneWidget);

    // 3. Ação: Tocar no botão
    await tester.tap(acceptButton);
    await tester.pumpAndSettle(); // Espera a persistência (Future) e a navegação

    // 4. Verificação de Navegação: Deve ir para a tela de Registro
    expect(find.text('Register Screen'), findsOneWidget);
    
    // 5. Verificação de Persistência: Checa se o valor foi salvo
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(_consentKey), isTrue);
  });
  
  testWidgets('ConsentScreen should not have a back button', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    
    // O AppBar deve ter automaticallyImplyLeading: false
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.automaticallyImplyLeading, isFalse);
    
    // Não deve encontrar o ícone de back button
    expect(find.byIcon(Icons.arrow_back), findsNothing);
  });
}