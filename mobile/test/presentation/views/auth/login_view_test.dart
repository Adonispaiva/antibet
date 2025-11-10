import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:go_router/go_router.dart';

import 'package:antibet/src/core/notifiers/auth_notifier.dart';
import 'package:antibet/src/presentation/views/auth/login_view.dart';

// Mocks
class MockAuthNotifier extends Mock implements AuthNotifier {
  @override
  Future<bool> login(String email, String password) => super.noSuchMethod(
        Invocation.method(#login, [email, password]),
        returnValue: Future.value(false), // Padrão é falha
      ) as Future<bool>;

  // Mock para simular o ChangeNotifier
  @override
  void addListener(VoidCallback listener) => super.noSuchMethod(Invocation.method(#addListener, [listener]), returnValue: null);
  @override
  void removeListener(VoidCallback listener) => super.noSuchMethod(Invocation.method(#removeListener, [listener]), returnValue: null);
}

// Helper para o AppRouter (necessário para testar context.go)
class MockGoRouterProvider extends StatelessWidget {
  const MockGoRouterProvider({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Configura um GoRouter com rotas de destino simuladas
    return GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const Text('Home Screen')),
        GoRoute(path: '/login', builder: (context, state) => child), // Tela sob teste
        GoRoute(path: '/register', builder: (context, state) => const Text('Register Screen')),
        GoRoute(path: '/forgot-password', builder: (context, state) => const Text('Forgot Password Screen')),
      ],
    ).createRouterWidget(context);
  }
}

Widget createWidgetUnderTest(MockAuthNotifier mockNotifier) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthNotifier>.value(value: mockNotifier),
    ],
    child: MockGoRouterProvider(
      child: const LoginView(),
    ),
  );
}

void main() {
  late MockAuthNotifier mockNotifier;

  setUp(() {
    mockNotifier = MockAuthNotifier();
  });

  group('LoginView Widget Tests', () {
    const validEmail = 'user@test.com';
    const validPassword = 'securepassword';

    testWidgets('Should successfully log in and navigate to home', (WidgetTester tester) async {
      // Setup: Mocka o login para retornar sucesso
      when(mockNotifier.login(validEmail, validPassword)).thenAnswer((_) => Future.value(true));

      await tester.pumpWidget(createWidgetUnderTest(mockNotifier));

      // 1. Preenche os campos
      await tester.enterText(find.byLabelText('E-mail'), validEmail);
      await tester.enterText(find.byLabelText('Senha'), validPassword);
      await tester.pump();

      // 2. Ação: Toca no botão Entrar
      await tester.tap(find.text('Entrar'));
      await tester.pump(); // Inicia o Future do login
      await tester.pumpAndSettle(); // Espera a conclusão do Future e a navegação

      // Verificação 1: O método login deve ser chamado com os dados corretos
      verify(mockNotifier.login(validEmail, validPassword)).called(1);

      // Verificação 2: Deve navegar para a Home Screen
      expect(find.text('Home Screen'), findsOneWidget);
    });

    testWidgets('Should display error message on failed login attempt', (WidgetTester tester) async {
      // Setup: Mocka o login para retornar falha (padrão)
      when(mockNotifier.login(any, any)).thenAnswer((_) => Future.value(false));

      await tester.pumpWidget(createWidgetUnderTest(mockNotifier));

      // 1. Preenche os campos
      await tester.enterText(find.byLabelText('E-mail'), validEmail);
      await tester.enterText(find.byLabelText('Senha'), validPassword);
      await tester.pump();

      // 2. Ação: Toca no botão Entrar
      await tester.tap(find.text('Entrar'));
      await tester.pump(); 
      await tester.pumpAndSettle(); // Espera a conclusão do Future e a atualização do erro

      // Verificação 1: Deve mostrar a mensagem de erro
      expect(find.text('Credenciais inválidas. Tente novamente.'), findsOneWidget);
      
      // Verificação 2: Deve continuar na tela de Login
      expect(find.text('Acesse sua conta AntiBet'), findsOneWidget);
    });

    testWidgets('Tapping "Cadastre-se" should navigate to Register Screen', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(mockNotifier));

      // Ação: Toca no link de Cadastro
      await tester.tap(find.text('Cadastre-se'));
      await tester.pumpAndSettle();

      // Verificação: Deve navegar para a tela de Registro
      expect(find.text('Register Screen'), findsOneWidget);
    });

    testWidgets('Tapping "Esqueceu a senha?" should navigate to Forgot Password Screen', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(mockNotifier));

      // Ação: Toca no link de Recuperação de Senha
      await tester.tap(find.text('Esqueceu a senha?'));
      await tester.pumpAndSettle();

      // Verificação: Deve navegar para a tela de Esqueci a Senha
      expect(find.text('Forgot Password Screen'), findsOneWidget);
    });
  });
}