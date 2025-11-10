import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:antibet/src/presentation/views/auth/forgot_password_view.dart';

// Helper para o AppRouter (necessário para testar context.go)
class MockGoRouterProvider extends StatelessWidget {
  const MockGoRouterProvider({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Configura um GoRouter com rotas de destino simuladas
    return GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => child), // Tela sob teste
        GoRoute(path: '/login', builder: (context, state) => const Text('Login Screen')),
      ],
    ).createRouterWidget(context);
  }
}

Widget createWidgetUnderTest() {
  return const MockGoRouterProvider(
    child: ForgotPasswordView(),
  );
}

void main() {
  group('ForgotPasswordView Widget Tests', () {
    const validEmail = 'recovery@test.com';

    testWidgets('Should successfully simulate password reset and show success message', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // 1. Verifica a presença do título
      expect(find.text('Recuperar Senha'), findsOneWidget);
      
      // 2. Preenche o e-mail
      await tester.enterText(find.byLabelText('E-mail'), validEmail);
      await tester.pump();

      // 3. Ação: Toca no botão Enviar Link
      await tester.tap(find.text('Enviar Link'));
      await tester.pump(); // Inicia o Future simulado
      await tester.pump(const Duration(seconds: 2)); // Espera a conclusão do Future (2s de delay simulado)
      await tester.pumpAndSettle();

      // Verificação 1: O indicador de carregamento (se houver) deve ter desaparecido
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Verificação 2: Deve mostrar a mensagem de sucesso
      expect(find.text('Um link de recuperação foi enviado para o seu e-mail.'), findsOneWidget);
    });

    testWidgets('Should show validation error for invalid email format', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // 1. Preenche o e-mail com formato inválido
      await tester.enterText(find.byLabelText('E-mail'), 'invalido');
      await tester.pump();

      // 2. Ação: Toca no botão Enviar Link
      await tester.tap(find.text('Enviar Link'));
      await tester.pumpAndSettle(); 

      // Verificação: Deve mostrar a mensagem de erro de validação
      expect(find.text('Insira um e-mail válido.'), findsOneWidget);
    });

    testWidgets('Tapping "Voltar para o Login" should navigate back to Login Screen', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Ação: Toca no link de retorno
      await tester.tap(find.text('Voltar para o Login'));
      await tester.pumpAndSettle();

      // Verificação: Deve navegar para a tela de Login
      expect(find.text('Login Screen'), findsOneWidget);
    });
  });
}