// ignore_for_file: cascade_invocations

import 'package:antibet/features/auth/presentation/login_screen.dart';
import 'package:antibet/features/auth/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// 1. Criamos um "Fake" Notifier para controlar o estado da UI
// Ele simula o UserProvider real, mas nos permite definir o estado manualmente.
class FakeUserNotifier extends StateNotifier<UserState> {
  FakeUserNotifier(UserState initialState) : super(initialState);

  int loginCallCount = 0;
  String? lastEmail;
  String? lastPassword;

  // Simula o método login, apenas registrando a chamada
  Future<void> login(String email, String password) async {
    loginCallCount++;
    lastEmail = email;
    lastPassword = password;
    // O estado será controlado manualmente pelo teste
  }

  // Helper para que o teste possa forçar um estado
  void setTestState(UserState newState) {
    state = newState;
  }
}

// ERRO CORRIGIDO: Adicionado '()'
void main() {
  late ProviderContainer container;
  late FakeUserNotifier fakeUserNotifier;

  setUp(() {
    // 2. Instanciamos nosso FakeNotifier
    fakeUserNotifier = FakeUserNotifier(UserInitial());

    // 3. Sobrescrevemos o provider real com o nosso fake
    container = ProviderContainer(
      overrides: [
        userProvider.overrideWith((ref) => fakeUserNotifier),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  // Função helper para inflar o widget
  Widget createWidgetUnderTest() {
    return ProviderScope(
      parent: container,
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  testWidgets('LoginScreen deve renderizar os campos e o botão',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());

    // Act
    final emailField = find.byKey(const ValueKey('loginEmailField'));
    final passwordField = find.byKey(const ValueKey('loginPasswordField'));
    final loginButton = find.byKey(const ValueKey('loginButton'));

    // Assert
    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(loginButton, findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets(
      'deve chamar provider.login() com os dados corretos ao pressionar o botão',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());

    // Act
    await tester.enterText(
        find.byKey(const ValueKey('loginEmailField')), 'test@example.com');
    await tester.enterText(
        find.byKey(const ValueKey('loginPasswordField')), 'password123');
    await tester.tap(find.byKey(const ValueKey('loginButton')));
    await tester.pump(); // Aguarda a animação do tap

    // Assert
    // 4. Verificamos se o nosso fake notifier foi chamado
    expect(fakeUserNotifier.loginCallCount, 1);
    expect(fakeUserNotifier.lastEmail, 'test@example.com');
    expect(fakeUserNotifier.lastPassword, 'password123');
  });

  testWidgets('deve exibir CircularProgressIndicator durante o estado UserLoading',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());

    // Act
    // 5. Forçamos o estado de loading no nosso fake
    fakeUserNotifier.setTestState(UserLoading());
    // Rebuilda o widget com o novo estado
    await tester.pump();

    // Assert
    // O botão deve sumir e o indicador de loading deve aparecer
    expect(find.byKey(const ValueKey('loginButton')), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('deve exibir SnackBar em caso de UserError',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());

    // Act
    // 6. Forçamos o estado de erro
    fakeUserNotifier.setTestState(UserError(message: 'Login falhou'));
    // Rebuilda
    await tester.pump();

    // Assert
    // O SnackBar deve aparecer
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Login falhou'), findsOneWidget);

    // Limpa o SnackBar
    await tester.pumpAndSettle();
  });
}