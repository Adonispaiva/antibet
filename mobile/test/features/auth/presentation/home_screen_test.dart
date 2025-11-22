// ignore_for_file: cascade_invocations

import 'package.antibet/features/auth/presentation/home_screen.dart';
import 'package:antibet/features/auth/presentation/login_screen.dart';
import 'package:antibet/features/auth/presentation/splash_screen.dart';
import 'package:antibet/features/auth/providers/user_provider.dart';
import 'package.antibet/features/journal/presentation/journal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package.flutter_test/flutter_test.dart';
import 'package:antibet/features/auth/models/user_model.dart';

// 1. Criamos um "Fake" Provider para controlar o estado da UI
// Diferente do FakeNotifier, este é um Provider simples que só retorna um estado
// que definimos no setup. É o suficiente para testar este widget.
final fakeUserProvider = Provider<UserState>((ref) {
  // O teste irá sobrepor isso, mas definimos um padrão
  return UserInitial();
});

void main() {
  // Modelo de Teste
  final tUserModel = UserModel(
      id: '1', name: 'Test User', email: 'test@example.com', token: 'token');

  // Função helper para inflar o widget com um estado específico
  Widget createWidgetUnderTest(UserState state) {
    return ProviderScope(
      overrides: [
        // 2. Sobrescrevemos o provider real com o nosso fake
        // e definimos o estado que queremos testar.
        userProvider.overrideWithProvider(Provider((ref) => state)),
      ],
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    );
  }

  testWidgets('HomeScreen deve renderizar SplashScreen no estado UserInitial',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest(UserInitial()));

    // Assert
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(JournalScreen), findsNothing);
  });

  testWidgets('HomeScreen deve renderizar SplashScreen no estado UserLoading',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest(UserLoading()));

    // Assert
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(JournalScreen), findsNothing);
  });

  testWidgets('HomeScreen deve renderizar LoginScreen no estado UserLoggedOut',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest(UserLoggedOut()));

    // Assert
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(JournalScreen), findsNothing);
  });

  testWidgets('HomeScreen deve renderizar LoginScreen no estado UserError',
      (WidgetTester tester) async {
    // Arrange
    // O estado de erro também deve levar ao Login
    await tester
        .pumpWidget(createWidgetUnderTest(const UserError(message: 'Falha')));

    // Assert
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(JournalScreen), findsNothing);
  });

  testWidgets('HomeScreen deve renderizar JournalScreen no estado UserLoaded',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest(UserLoaded(user: tUserModel)));

    // Assert
    expect(find.byType(JournalScreen), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(LoginScreen), findsNothing);
  });
}