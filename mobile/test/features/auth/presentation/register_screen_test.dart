// ignore_for_file: cascade_invocations

import 'package:antibet/features/auth/presentation/register_screen.dart';
import 'package:antibet/features/auth/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package.flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// 1. Reutilizamos o "Fake" Notifier para controlar o estado da UI
// (Este helper pode ser movido para um arquivo 'test_helpers.dart' no futuro)
class FakeUserNotifier extends StateNotifier<UserState> {
  FakeUserNotifier(UserState initialState) : super(initialState);

  int registerCallCount = 0;
  String? lastEmail;
  String? lastName;
  String? lastPassword;

  // Simula o método register
  Future<void> register({
    required String email,
    required String name,
    required String password,
  }) async {
    registerCallCount++;
    lastEmail = email;
    lastName = name;
    lastPassword = password;
  }

  // Helper para que o teste possa forçar um estado
  void setTestState(UserState newState) {
    state = newState;
  }
}

void main() {
  late ProviderContainer container;
  late FakeUserNotifier fakeUserNotifier;

  setUp(() {
    fakeUserNotifier = FakeUserNotifier(UserInitial());
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
        home: RegisterScreen(),
      ),
    );
  }

  testWidgets('RegisterScreen deve renderizar os campos e o botão',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());

    // Act
    final nameField = find.byKey(const ValueKey('registerNameField'));
    final emailField = find.byKey(const ValueKey('registerEmailField'));
    final passwordField = find.byKey(const ValueKey('registerPasswordField'));
    final registerButton = find.byKey(const ValueKey('registerButton'));

    // Assert
    expect(nameField, findsOneWidget);
    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(registerButton, findsOneWidget);
    expect(find.text('Cadastrar'), findsOneWidget);
  });

  testWidgets(
      'deve chamar provider.register() com os dados corretos ao pressionar o botão',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());

    // Act
    await tester.enterText(
        find.byKey(const ValueKey('registerNameField')), 'Test User');
    await tester.enterText(
        find.byKey(const ValueKey('registerEmailField')), 'test@example.com');
    await tester.enterText(
        find.byKey(const ValueKey('registerPasswordField')), 'password123');
    await tester.tap(find.byKey(const ValueKey('registerButton')));
    await tester.pump(); 

    // Assert
    expect(fakeUserNotifier.registerCallCount, 1);
    expect(fakeUserNotifier.lastName, 'Test User');
    expect(fakeUserNotifier.lastEmail, 'test@example.com');
    expect(fakeUserNotifier.lastPassword, 'password123');
  });

  testWidgets('deve exibir CircularProgressIndicator durante o estado UserLoading',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());

    // Act
    fakeUserNotifier.setTestState(UserLoading());
    await tester.pump();

    // Assert
    expect(find.byKey(const ValueKey('registerButton')), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('deve exibir SnackBar em caso de UserError',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());

    // Act
    fakeUserNotifier.setTestState(UserError(message: 'Cadastro falhou'));
    await tester.pump();

    // Assert
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Cadastro falhou'), findsOneWidget);

    await tester.pumpAndSettle();
  });
}