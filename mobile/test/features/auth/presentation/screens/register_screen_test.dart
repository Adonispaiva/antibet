import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:antibet/features/auth/data/services/auth_service.dart';
import 'package:antibet/features/auth/presentation/screens/register_screen.dart';

// Mock do AuthService
class MockAuthService extends Mock implements AuthService {}

// Wrapper para simular o ProviderScope e o contexto de navegação
class TestRegisterWrapper extends StatelessWidget {
  final Widget child;
  final MockAuthService mockAuthService;

  const TestRegisterWrapper({super.key, required this.child, required this.mockAuthService});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }
}

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    // Registra o fallback para a função `register` do MockAuthService
    registerFallbackValue('any_email');
    registerFallbackValue('any_password');
  });

  group('RegisterScreen Widget Test', () {
    const tEmail = 'newuser@inovexa.com';
    const tPassword = 'NewPassword123';

    testWidgets('should show error when required fields are empty', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(TestRegisterWrapper(
        child: const RegisterScreen(),
        mockAuthService: mockAuthService,
      ));

      // Act: Tenta registrar com campos vazios
      await tester.tap(find.byKey(const Key('register_submit_button')));
      await tester.pump(); // Aciona a validação

      // Assert
      expect(find.text('Por favor, insira seu e-mail.'), findsOneWidget);
      expect(find.text('Por favor, crie uma senha.'), findsOneWidget);
      expect(find.text('Confirme sua senha.'), findsOneWidget);
      verifyNever(() => mockAuthService.register(any(), any()));
    });

    testWidgets('should call authService.register and navigate to login on success', (WidgetTester tester) async {
      // Arrange
      // Simula o sucesso do registro
      when(() => mockAuthService.register(tEmail, tPassword)).thenAnswer((_) async {});

      await tester.pumpWidget(TestRegisterWrapper(
        child: Builder(
          builder: (context) {
            // Mocking the navigation context (GoRouter)
            return GoRouter(
              routes: [
                GoRoute(path: '/', builder: (c, s) => const RegisterScreen()),
                GoRoute(path: '/login', builder: (c, s) => const Text('Login Screen')),
              ],
              initialLocation: '/',
            );
          },
        ),
        mockAuthService: mockAuthService,
      ));

      // Act: Preenche os campos
      await tester.enterText(find.byKey(const Key('register_email_field')), tEmail);
      await tester.enterText(find.byKey(const Key('register_password_field')), tPassword);
      await tester.enterText(find.byKey(const Key('register_confirm_password_field')), tPassword);
      await tester.pumpAndSettle();

      // Act: Toca no botão de registro
      await tester.tap(find.byKey(const Key('register_submit_button')));
      await tester.pump(); // Loading state
      
      // Simula o tempo de API e a navegação
      await tester.pumpAndSettle(const Duration(seconds: 1)); 

      // Assert
      // Verifica se o registro foi chamado
      verify(() => mockAuthService.register(tEmail, tPassword)).called(1);
      
      // Verifica a navegação para a tela de login
      expect(find.text('Login Screen'), findsOneWidget);
      
      // Verifica o SnackBar de sucesso
      expect(find.text('Conta criada com sucesso! Faça login.'), findsOneWidget);
    });

    testWidgets('should show error message on registration failure', (WidgetTester tester) async {
      // Arrange
      const tErrorMessage = 'E-mail já registrado.';
      // Simula a falha do registro
      when(() => mockAuthService.register(tEmail, tPassword))
          .thenThrow(Exception(tErrorMessage));

      await tester.pumpWidget(TestRegisterWrapper(
        child: const RegisterScreen(),
        mockAuthService: mockAuthService,
      ));

      // Act: Preenche os campos
      await tester.enterText(find.byKey(const Key('register_email_field')), tEmail);
      await tester.enterText(find.byKey(const Key('register_password_field')), tPassword);
      await tester.enterText(find.byKey(const Key('register_confirm_password_field')), tPassword);
      await tester.pumpAndSettle();

      // Act: Toca no botão de registro
      await tester.tap(find.byKey(const Key('register_submit_button')));
      await tester.pump(); // Loading state
      await tester.pump(const Duration(milliseconds: 500)); // Simula o SnackBar aparecer

      // Assert
      // Verifica se a mensagem de erro aparece no SnackBar
      expect(find.text(tErrorMessage), findsOneWidget);
      
      // Garante que permaneceu na tela de registro
      expect(find.byType(RegisterScreen), findsOneWidget);
    });
  });
}