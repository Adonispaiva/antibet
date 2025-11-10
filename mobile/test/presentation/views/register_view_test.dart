import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Importações dos componentes a serem testados e dependências
import 'package:antibet_mobile/infra/services/auth_service.dart';
import 'package:antibet_mobile/notifiers/auth_notifier.dart';
import 'package:antibet_mobile/presentation/views/register_view.dart';

// Gera o mock para o AuthNotifier (reutilizando a geração se já foi feita)
@GenerateMocks([AuthNotifier])
import 'register_view_test.mocks.dart'; 

// Widget Wrapper que simula o ambiente da aplicação (MaterialApp e Provider)
Widget createRegisterScreen({required AuthNotifier mockNotifier}) {
  return MaterialApp(
    home: ChangeNotifierProvider<AuthNotifier>.value(
      value: mockNotifier,
      child: const RegisterView(),
    ),
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

  group('RegisterView Widget Tests', () {

    // Helper para encontrar os campos de texto
    Finder findEmailField() => find.byWidgetPredicate(
      (widget) => widget is TextFormField && widget.decoration?.labelText == 'Email',
    );
    Finder findPasswordField() => find.byWidgetPredicate(
      (widget) => widget is TextFormField && widget.decoration?.labelText == 'Senha',
    );
    Finder findConfirmPasswordField() => find.byWidgetPredicate(
      (widget) => widget is TextFormField && widget.decoration?.labelText == 'Confirme a Senha',
    );
    Finder findRegisterButton() => find.widgetWithText(ElevatedButton, 'Registrar');
    Finder findBackButton() => find.widgetWithText(TextButton, 'Já tenho uma conta');

    // --- Teste 1: Estrutura Básica ---
    testWidgets('RegisterView exibe todos os campos e botões', (WidgetTester tester) async {
      await tester.pumpWidget(createRegisterScreen(mockNotifier: mockAuthNotifier));

      expect(find.text('Criar Nova Conta'), findsOneWidget);
      expect(findEmailField(), findsOneWidget);
      expect(findPasswordField(), findsOneWidget);
      expect(findConfirmPasswordField(), findsOneWidget);
      expect(findRegisterButton(), findsOneWidget);
      expect(findBackButton(), findsOneWidget);
    });

    // --- Teste 2: Validação de Campos Vazios ---
    testWidgets('Submissão falha se os campos estiverem vazios', (WidgetTester tester) async {
      await tester.pumpWidget(createRegisterScreen(mockNotifier: mockAuthNotifier));

      await tester.tap(findRegisterButton());
      await tester.pump(); 

      // Verifica as mensagens de erro de validação
      expect(find.text('Digite um email válido'), findsOneWidget);
      expect(find.text('A senha deve ter pelo menos 8 caracteres'), findsOneWidget);
      expect(find.text('Confirme a senha'), findsOneWidget);
      
      verifyNever(mockAuthNotifier.register(any, any));
    });

    // --- Teste 3: Validação de Senhas Diferentes ---
    testWidgets('Submissão falha se as senhas não coincidirem', (WidgetTester tester) async {
      await tester.pumpWidget(createRegisterScreen(mockNotifier: mockAuthNotifier));

      await tester.enterText(findEmailField(), 'test@user.com');
      await tester.enterText(findPasswordField(), '12345678');
      await tester.enterText(findConfirmPasswordField(), '87654321'); // Senhas diferentes

      await tester.tap(findRegisterButton());
      await tester.pump(); 

      // Verifica a mensagem de erro de confirmação
      expect(find.text('As senhas não coincidem'), findsOneWidget);
      
      verifyNever(mockAuthNotifier.register(any, any));
    });

    // --- Teste 4: Registro Bem-Sucedido ---
    testWidgets('Registro bem-sucedido chama AuthNotifier.register() e mostra sucesso', (WidgetTester tester) async {
      // Configuração: Simula sucesso no registro
      when(mockAuthNotifier.register('new@user.com', 'securepass')).thenAnswer((_) async {});
      
      await tester.pumpWidget(createRegisterScreen(mockNotifier: mockAuthNotifier));

      // Preenche os campos
      await tester.enterText(findEmailField(), 'new@user.com');
      await tester.enterText(findPasswordField(), 'securepass');
      await tester.enterText(findConfirmPasswordField(), 'securepass');

      await tester.tap(findRegisterButton());
      await tester.pump(); // Inicia o estado de carregamento

      // Verifica o estado de carregamento (indicador)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(); // Aguarda o Future e a exibição do diálogo

      // Verifica se o método correto foi chamado no Notifier
      verify(mockAuthNotifier.register('new@user.com', 'securepass')).called(1);
      
      // Verifica se o dialog de sucesso está na tela
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Sucesso!'), findsOneWidget);
      expect(find.text('Conta criada e login realizado com sucesso!'), findsOneWidget);
      
      // Toca no OK para fechar o diálogo
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    // --- Teste 5: Registro Mal-Sucedido com Erro (AuthException) ---
    testWidgets('Registro mal-sucedido exibe dialog de erro', (WidgetTester tester) async {
      const AuthException testError = AuthException('Email já está em uso ou inválido.');
      
      // Configuração: Simula falha no registro com exceção
      when(mockAuthNotifier.register('fail@user.com', 'securepass')).thenThrow(testError);
      
      await tester.pumpWidget(createRegisterScreen(mockNotifier: mockAuthNotifier));

      // Preenche os campos
      await tester.enterText(findEmailField(), 'fail@user.com');
      await tester.enterText(findPasswordField(), 'securepass');
      await tester.enterText(findConfirmPasswordField(), 'securepass');

      await tester.tap(findRegisterButton());
      await tester.pump(); 

      await tester.pumpAndSettle(); 

      // Verifica se o dialog de erro está na tela
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Falha no Registro'), findsOneWidget);
      expect(find.text('Email já está em uso ou inválido.'), findsOneWidget);

      // Toca no OK e verifica se o dialog fecha
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}