// ignore_for_file: cascade_invocations

import 'package.antibet/core/errors/failures.dart';
import 'package:antibet/core/services/secure_storage_service.dart';
import 'package:antibet/features/auth/models/user_model.dart';
import 'package:antibet/features/auth/presentation/login_screen.dart';
import 'package:antibet/features/auth/services/auth_service.dart';
import 'package:antibet/features/journal/presentation/journal_screen.dart';
import 'package:antibet/main.dart' as app;
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks/core/services/storage_service.mocks.dart';
import '../mocks/features/auth/services/auth_service.mocks.dart';

void main() {
  // 1. Garante que os bindings de integração estão inicializados
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Mocks
  late MockAuthService mockAuthService;
  late MockSecureStorageService mockSecureStorageService;
  late ProviderContainer container;

  // Modelo de Teste
  final tUserModel = UserModel(
    id: '1',
    name: 'Integration User',
    email: 'integration@test.com',
    token: 'fake-token-integration',
  );

  setUp(() {
    mockAuthService = MockAuthService();
    mockSecureStorageService = MockSecureStorageService();
  });

  // Função helper para inflar o app com os providers mockados
  Future<void> pumpApp(WidgetTester tester) async {
    // 2. Sobrescrevemos os providers no 'main.dart'
    // A app.main() será chamada, mas com estas sobreposições
    app.main(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
        secureStorageServiceProvider.overrideWithValue(mockSecureStorageService),
      ],
    );
    // Aguarda o app renderizar
    await tester.pumpAndSettle();
  }

  testWidgets('Fluxo de Login - Sucesso', (WidgetTester tester) async {
    // --- ARRANGE ---

    // 3. Mock da lógica de 'loadUser' (para o splash_screen)
    // O app começa, o splash_screen tenta carregar. Mockamos como 'null'.
    when(mockSecureStorageService.read(key: 'user'))
        .thenAnswer((_) async => null);

    // 4. Mock da lógica de 'login'
    when(mockAuthService.login('test@example.com', 'password123'))
        .thenAnswer((_) async => Right(tUserModel));
    // Mock do 'write' no storage após o login
    when(mockSecureStorageService.write(key: 'user', value: any))
        .thenAnswer((_) async => _);

    // --- ACT ---

    // 5. Renderiza o app (que começará no SplashScreen -> LoginScreen)
    await pumpApp(tester);

    // Verifica se estamos na tela de Login
    expect(find.byType(LoginScreen), findsOneWidget);

    // 6. Simula a interação do usuário
    await tester.enterText(
        find.byKey(const ValueKey('loginEmailField')), 'test@example.com');
    await tester.enterText(
        find.byKey(const ValueKey('loginPasswordField')), 'password123');
    
    // Tapa no botão de login
    await tester.tap(find.byKey(const ValueKey('loginButton')));

    // 7. Aguarda a transição de estado e navegação
    // O pumpAndSettle aguarda todas as animações e futuros (como a chamada de login)
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // --- ASSERT ---

    // 8. Verifica o resultado
    // Não devemos mais estar na LoginScreen
    expect(find.byType(LoginScreen), findsNothing);
    // Devemos agora estar na JournalScreen (Home)
    expect(find.byType(JournalScreen), findsOneWidget);
    // Verifica se o nome do usuário (do mock) está na tela
    expect(find.text('Olá, Integration User'), findsOneWidget);
  });

   testWidgets('Fluxo de Login - Falha', (WidgetTester tester) async {
    // --- ARRANGE ---
    // Mock do 'loadUser' (para o splash_screen)
    when(mockSecureStorageService.read(key: 'user'))
        .thenAnswer((_) async => null);

    // Mock da lógica de 'login' (desta vez, falhando)
    when(mockAuthService.login('test@example.com', 'wrongpassword'))
        .thenAnswer((_) async => Left(AuthFailure(message: 'Credenciais inválidas')));

    // --- ACT ---
    await pumpApp(tester);

    // Verifica se estamos na tela de Login
    expect(find.byType(LoginScreen), findsOneWidget);

    // Simula a interação
    await tester.enterText(
        find.byKey(const ValueKey('loginEmailField')), 'test@example.com');
    await tester.enterText(
        find.byKey(const ValueKey('loginPasswordField')), 'wrongpassword');
    
    await tester.tap(find.byKey(const ValueKey('loginButton')));

    // Aguarda o estado (loading) e a exibição do SnackBar
    await tester.pumpAndSettle(); 

    // --- ASSERT ---
    // Devemos continuar na LoginScreen
    expect(find.byType(LoginScreen), findsOneWidget);
    // A JournalScreen não deve aparecer
    expect(find.byType(JournalScreen), findsNothing);
    // O SnackBar de erro deve estar visível
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Credenciais inválidas'), findsOneWidget);
  });
}