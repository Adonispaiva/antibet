import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:antibet/core/local_storage/storage_service.dart'; // Import para persistência
import 'package:antibet/features/auth/data/services/auth_service.dart';
import 'package:antibet/features/auth/presentation/providers/auth_provider.dart';
import 'package:antibet/features/auth/presentation/screens/login_screen.dart';

// Mocks
class MockAuthService extends Mock implements AuthService {}
class MockStorageService extends Mock implements StorageService {}

// Wrapper para simular o ProviderScope e o contexto de navegação com dependências
class TestLoginWrapper extends StatelessWidget {
  final Widget child;
  final MockAuthService mockAuthService;
  final MockStorageService mockStorageService;

  const TestLoginWrapper({
    super.key, 
    required this.child, 
    required this.mockAuthService,
    required this.mockStorageService,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
        // Sobrescreve o storageServiceProvider
        storageServiceProvider.overrideWithValue(mockStorageService),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) {
            // Mocking the navigation context (GoRouter)
            return GoRouter(
              routes: [
                GoRoute(path: '/', builder: (c, s) => const LoginScreen()),
                GoRoute(path: '/journal', builder: (c, s) => const Text('Journal Screen')),
              ],
              initialLocation: '/',
            );
          },
        ),
      ),
    );
  }
}

void main() {
  late MockAuthService mockAuthService;
  late MockStorageService mockStorageService;

  setUp(() {
    mockAuthService = MockAuthService();
    mockStorageService = MockStorageService();
    
    // Configuração básica do StorageService para não interferir na inicialização
    when(() => mockStorageService.getString(any())).thenReturn(null);
    when(() => mockStorageService.setString(any(), any())).thenAnswer((_) async => true);

    registerFallbackValue('any_email');
    registerFallbackValue('any_password');
  });

  group('LoginScreen Persistence and Authentication Test', () {
    const tEmail = 'test@inovexa.com';
    const tPassword = 'Password123';
    const tToken = 'jwt_token_123';

    testWidgets('should call authService.login, persist token, and navigate on success', (WidgetTester tester) async {
      // Arrange
      // Simula o sucesso do login
      when(() => mockAuthService.login(tEmail, tPassword)).thenAnswer((_) async => tToken);

      await tester.pumpWidget(TestLoginWrapper(
        mockAuthService: mockAuthService,
        mockStorageService: mockStorageService,
        child: const LoginScreen(),
      ));

      // Act: Preenche os campos
      await tester.enterText(find.byKey(const Key('email_field')), tEmail);
      await tester.enterText(find.byKey(const Key('password_field')), tPassword);
      await tester.pumpAndSettle();

      // Act: Toca no botão de login
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump(); // Loading state
      
      // Simula o tempo de API e a navegação
      await tester.pumpAndSettle(const Duration(seconds: 1)); 

      // Assert
      // 1. Verifica se o login foi chamado
      verify(() => mockAuthService.login(tEmail, tPassword)).called(1);
      
      // 2. **Verifica se o token foi persistido** (Nova funcionalidade da Fase III)
      verify(() => mockStorageService.setString('auth_token', tToken)).called(1);
      
      // 3. Verifica a navegação
      expect(find.text('Journal Screen'), findsOneWidget);
    });

    testWidgets('should show error message on login failure (no token persistence)', (WidgetTester tester) async {
      // Arrange
      const tErrorMessage = 'Credenciais inválidas';
      when(() => mockAuthService.login(tEmail, tPassword))
          .thenThrow(Exception(tErrorMessage));

      await tester.pumpWidget(TestLoginWrapper(
        mockAuthService: mockAuthService,
        mockStorageService: mockStorageService,
        child: const LoginScreen(),
      ));

      // Act: Toca no botão de login
      await tester.enterText(find.byKey(const Key('email_field')), tEmail);
      await tester.enterText(find.byKey(const Key('password_field')), tPassword);
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump(); 
      await tester.pump(const Duration(milliseconds: 500));

      // Assert
      // 1. Verifica se a mensagem de erro aparece
      expect(find.text(tErrorMessage), findsOneWidget);
      
      // 2. **Garante que nenhuma operação de escrita foi chamada no StorageService**
      verifyNever(() => mockStorageService.setString(any(), any()));
      
      // 3. Garante que permaneceu na tela de Login
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}