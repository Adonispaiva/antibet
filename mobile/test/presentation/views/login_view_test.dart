import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Importações dos componentes a serem testados e dependências
import 'package:antibet_mobile/infra/services/auth_service.dart';
import 'package:antibet_mobile/notifiers/auth_notifier.dart';
import 'package:antibet_mobile/presentation/views/login_view.dart';
import 'package:antibet_mobile/presentation/views/register_view.dart';

// Gera o mock para o AuthNotifier (pois é o que o Widget consome)
@GenerateMocks([AuthNotifier])
import 'login_view_test.mocks.dart'; 

// Widget Wrapper que simula o ambiente da aplicação (MaterialApp e Provider)
Widget createLoginScreen({required AuthNotifier mockNotifier}) {
  return MaterialApp(
    home: ChangeNotifierProvider<AuthNotifier>.value(
      value: mockNotifier,
      child: const LoginView(),
    ),
    // Adiciona a rota de registro para o teste de navegação
    routes: {
      '/register': (context) => const RegisterView(), // Rota fictícia, mas necessária
    },
  );
}

void main() {
  late MockAuthNotifier mockAuthNotifier;

  setUp(() {
    mockAuthNotifier = MockAuthNotifier();
    // Configura o estado inicial padrão para evitar nulls
    when(mockAuthNotifier.state).thenReturn(AuthState.unauthenticated);
    when(mockAuthNotifier.isAuthenticated).thenReturn(false);
  });

  group('LoginView Widget Tests', () {

    // Helper para encontrar os campos de texto
    Finder findEmailField() => find.byWidgetPredicate(
      (widget) => widget is TextFormField && widget.decoration?.labelText == 'Email',
    );
    Finder findPasswordField() => find.byWidgetPredicate(
      (widget) => widget is TextFormField && widget.decoration?.labelText == 'Senha',
    );
    Finder findLoginButton() => find.widgetWithText(ElevatedButton, 'Entrar');
    Finder findRegisterButton() => find.widgetWithText(TextButton, 'Não tem conta? Cadastre-se');

    // --- Teste 1: Estrutura Básica ---
    testWidgets('LoginView exibe os campos de formulário e botões', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen(mockNotifier: mockAuthNotifier));

      expect(find.text('Login - AntiBet Mobile'), findsOneWidget);
      expect(findEmailField(), findsOneWidget);
      expect(findPasswordField(), findsOneWidget);
      expect(findLoginButton(), findsOneWidget);
      expect(findRegisterButton(), findsOneWidget);
    });

    // --- Teste 2: Navegação para Registro ---
    testWidgets('Toca no botão de registro e navega para RegisterView', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen(mockNotifier: mockAuthNotifier));
      
      // Simula o toque no botão de navegação
      await tester.tap(findRegisterButton());
      await tester.pumpAndSettle(); // Aguarda a animação de navegação

      // Verifica se a nova tela foi carregada
      expect(find.text('Criar Nova Conta'), findsOneWidget);
    });

    // --- Teste 3: Validação de Formulário ---
    testWidgets('Submissão falha se os campos estiverem vazios', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen(mockNotifier: mockAuthNotifier));

      // Toca no botão de login sem preencher nada
      await tester.tap(findLoginButton());
      await tester.pump(); // Atualiza a UI para mostrar erros

      // Verifica se as mensagens de erro de validação aparecem
      expect(find.text('Digite um email válido'), findsOneWidget);
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      
      // Verifica que o login do Notifier nunca foi chamado
      verifyNever(mockAuthNotifier.login(any, any));
    });

    // --- Teste 4: Login Bem-Sucedido ---
    testWidgets('Submissão bem-sucedida chama AuthNotifier.login()', (WidgetTester tester) async {
      // Configuração: Simula sucesso no login
      when(mockAuthNotifier.login('valid@test.com', '123456')).thenAnswer((_) async {});
      
      await tester.pumpWidget(createLoginScreen(mockNotifier: mockAuthNotifier));

      // Preenche os campos
      await tester.enterText(findEmailField(), 'valid@test.com');
      await tester.enterText(findPasswordField(), '123456');

      // Toca no botão de login
      await tester.tap(findLoginButton());
      await tester.pump(); // Inicia o estado de carregamento

      // Verifica o estado de carregamento (indicador)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(); // Aguarda o Future.delayed (se houvesse) e o fim do login

      // Verifica se o método correto foi chamado no Notifier
      verify(mockAuthNotifier.login('valid@test.com', '123456')).called(1);
      
      // Verifica que o indicador desapareceu
      expect(find.byType(CircularProgressIndicator), findsNothing);
      
      // Nota: A navegação em si é tratada pelo AuthGate (em main.dart), não por LoginView.
    });

    // --- Teste 5: Login Mal-Sucedido com Erro (AuthException) ---
    testWidgets('Login mal-sucedido exibe dialog de erro', (WidgetTester tester) async {
      const AuthException testError = AuthException('Credenciais inválidas.');
      
      // Configuração: Simula falha no login com exceção
      when(mockAuthNotifier.login('invalid@test.com', 'wrong')).thenThrow(testError);
      
      await tester.pumpWidget(createLoginScreen(mockNotifier: mockAuthNotifier));

      // Preenche os campos
      await tester.enterText(findEmailField(), 'invalid@test.com');
      await tester.enterText(findPasswordField(), 'wrong');

      await tester.tap(findLoginButton());
      await tester.pump(); // Inicia o estado de carregamento

      // O pumpAndSettle faz com que o futuro seja resolvido e o dialog apareça
      await tester.pumpAndSettle(); 

      // Verifica se o dialog de erro está na tela
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Falha no Login'), findsOneWidget);
      expect(find.text('Credenciais inválidas.'), findsOneWidget);

      // Toca no OK e verifica se o dialog fecha
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      
      verify(mockAuthNotifier.login('invalid@test.com', 'wrong')).called(1);
    });
  });
}