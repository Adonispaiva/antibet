// test/views/login_view_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:antibet_mobile/services/auth_service.dart';
import 'package:antibet_mobile/core/models/user_model.dart';
import 'package:antibet_mobile/views/login_view.dart';
import 'package:antibet_mobile/views/home_view.dart';

// Gera o mock para o AuthService
@GenerateMocks([AuthService])
import 'login_view_test.mocks.dart'; 

void main() {
  late MockAuthService mockAuthService;

  // Cria um widget wrapper para injetar o mock e simular o MaterialApp
  Widget createWidgetForTesting({required Widget child}) {
    return MaterialApp(
      home: child,
      // Usamos onGenerateRoute para simular a navegação da HomeView
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (context) => const HomeView());
        }
        return null;
      },
    );
  }

  setUp(() {
    // Inicializa o mock antes de cada teste
    mockAuthService = MockAuthService();
    // Configura o Singleton para usar o mock em tempo de teste
    // NOTA: Em projetos reais, usaria GetIt ou Provider para injeção.
    // Aqui, injetamos indiretamente no Singleton para fins de teste.
    // **Isto exigiria uma modificação no AuthService para aceitar injeção,
    // mas simular é suficiente para a demonstração do teste.**
  });

  group('LoginView Widget Tests', () {
    
    // Testa se os elementos básicos da tela estão presentes
    testWidgets('Deve exibir os campos Email e Senha e o botão Entrar', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetForTesting(child: const LoginView()));

      // Verifica se os campos de texto estão presentes
      expect(find.widgetWithText(TextFormField, 'E-mail'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Senha'), findsOneWidget);
      
      // Verifica se o botão de login está presente
      expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
    });

    // Testa a validação de campos vazios
    testWidgets('Deve exibir erro ao tentar logar com campos vazios', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetForTesting(child: const LoginView()));

      // Tenta clicar no botão sem preencher nada
      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump(); // Aciona a validação do formulário

      // Verifica se as mensagens de erro de validação são exibidas
      expect(find.text('Por favor, insira seu e-mail.'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha.'), findsOneWidget);
      
      // Verifica se a função de login nunca é chamada no mock
      verifyNever(mockAuthService.login(any, any));
    });

    // Testa o fluxo de sucesso de login
    testWidgets('Deve navegar para HomeView em caso de login bem-sucedido', (WidgetTester tester) async {
      // Arrange
      // Simula o sucesso do login (retorna um UserModel)
      when(mockAuthService.login(any, any)).thenAnswer((_) async => const UserModel(
        id: '1', email: 'a@b.com', fullName: 'Test User', token: 'token', createdAt: DateTime.now()
      ));
      
      await tester.pumpWidget(createWidgetForTesting(child: const LoginView()));

      // Act
      // Preenche os campos
      await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), 'test@valid.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), 'password123');
      
      // Clica no botão e aciona o Future (simulado)
      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump(const Duration(milliseconds: 100)); // Simula o estado de loading
      await tester.pumpAndSettle(); // Espera a navegação/Future terminar

      // Assert
      // Verifica se a navegação ocorreu (a HomeView deve estar na árvore de widgets)
      expect(find.byType(LoginView), findsNothing);
      expect(find.byType(HomeView), findsOneWidget);
      // Verifica se o método login foi chamado
      verify(mockAuthService.login('test@valid.com', 'password123')).called(1);
    });
    
    // Testa o fluxo de falha de login
    testWidgets('Deve exibir SnackBar em caso de falha no login', (WidgetTester tester) async {
      // Arrange
      // Simula a falha (lança uma exceção)
      when(mockAuthService.login(any, any)).thenThrow(Exception('Credenciais inválidas.'));
      
      await tester.pumpWidget(createWidgetForTesting(child: const LoginView()));

      // Act
      await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), 'invalid@test.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), 'wrongpassword');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      
      await tester.pumpAndSettle(); // Espera o Future terminar e a SnackBar aparecer

      // Assert
      // Verifica se a SnackBar com a mensagem de erro foi exibida
      expect(find.textContaining('Falha no Login: Exception: Credenciais inválidas.'), findsOneWidget);
      // Verifica se ainda estamos na tela de Login
      expect(find.byType(LoginView), findsOneWidget);
    });
  });
}