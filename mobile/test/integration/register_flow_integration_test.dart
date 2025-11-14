import 'package:antibet/core/notifiers/auth_notifier.dart';
import 'package:antibet/core/services/auth_service.dart';
import 'package:antibet/mobile/presentation/screens/auth/register_screen.dart';
import 'package:antibet/mobile/presentation/screens/auth/login_screen.dart'; // Target screen after successful registration
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Mocks essenciais para o fluxo de autenticação
class MockAuthService extends Mock implements AuthService {}
class MockAuthNotifier extends Mock implements AuthNotifier {}

void main() {
  MockAuthService mockAuthService;
  MockAuthNotifier mockAuthNotifier;
  
  // Cria um GoRouter de teste para simular a navegação
  late GoRouter router; 

  setUp(() {
    mockAuthService = MockAuthService();
    mockAuthNotifier = MockAuthNotifier();
    
    // Configura o mock notifier para simular o estado inicial (não autenticado)
    when(mockAuthNotifier.isAuthenticated).thenReturn(false); 
    when(mockAuthNotifier.isLoading).thenReturn(false);
    
    // Configura o mock do serviço para simular o sucesso do registro
    when(mockAuthService.register(any, any, any)).thenAnswer((_) async => true);
    
    // Configuração do Router de Teste
    router = GoRouter(
      initialLocation: '/register', // Inicia na tela de Registro
      routes: [
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        // Adicionar outras rotas importantes se necessário (ex: /home)
      ],
      // O RefreshListenable não é crítico aqui, pois o registro geralmente redireciona manualmente.
      redirect: (BuildContext context, GoRouterState state) {
        // Regra simples: Se tentar acessar login/home sem registro, fica no registro.
        // Simplificamos o redirecionamento para focar no fluxo de registro -> login.
        return null; 
      },
    );
  });
  
  // Helper function para envelopar o widget no ambiente de MultiProvider e GoRouter
  Widget createRegisterFlowTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthNotifier>.value(value: mockAuthNotifier),
        // Em um teste de integração real, você injetaria o AuthService no Notifier se ele não for mockado.
        // Aqui, o Notifier é mockado, e o teste verifica a interação com o Notifier.
      ],
      child: MaterialApp.router(
        routerDelegate: router.routerDelegate,
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
      ),
    );
  }

  group('Register Flow Integration Test', () {
    testWidgets('Successful registration navigates from RegisterScreen to LoginScreen', (WidgetTester tester) async {
      // 1. Build the initial widget (RegisterScreen)
      await tester.pumpWidget(createRegisterFlowTestWidget());
      await tester.pumpAndSettle(); // Renders the RegisterScreen

      // Verification: Check if the RegisterScreen is visible
      expect(find.byType(RegisterScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
      
      // 2. Simulate filling the form
      // Assuming keys are used for inputs in RegisterScreen
      await tester.enterText(find.byKey(const Key('email_input')), 'newuser@inovexa.com');
      await tester.enterText(find.byKey(const Key('password_input')), 'securepass123');
      await tester.enterText(find.byKey(const Key('confirm_password_input')), 'securepass123');


      // 3. Mock the internal state change in the Notifier/Service call
      // Quando a UI chama o AuthNotifier.register(), o Notifier internamente chama o AuthService.register().
      // Aqui simulamos que o Notifier chama o Service e retorna sucesso.
      when(mockAuthNotifier.register(any, any, any)).thenAnswer((_) async => true);

      // 4. Tap the Register button (assuming an 'Register' text on the button)
      await tester.tap(find.text('Register'));
      await tester.pump(); // Inicia a rebuild e a navegação (simulando a chamada ao GoRouter.go())
      await tester.pumpAndSettle(); // Finaliza a animação de navegação/redirecionamento

      // 5. Verification: Check if the navigation succeeded (LoginScreen is visible)
      expect(find.byType(RegisterScreen), findsNothing);
      expect(find.byType(LoginScreen), findsOneWidget);
      
      // Verification: Check if the AuthNotifier register method was called
      verify(mockAuthNotifier.register(
        argThat(equals('newuser@inovexa.com')),
        argThat(equals('securepass123')),
        argThat(equals('securepass123')),
      )).called(1);
    });

    // Future tests:
    // - testWidgets('Failed registration shows error message on RegisterScreen')
    // - testWidgets('Password mismatch shows validation error')
  });
}