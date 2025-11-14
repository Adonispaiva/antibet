import 'package:antibet/core/notifiers/auth_notifier.dart';
import 'package:antibet/core/services/auth_service.dart';
import 'package:antibet/mobile/presentation/screens/auth/login_screen.dart';
import 'package:antibet/mobile/presentation/screens/home_screen.dart'; // Target screen
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // Assuming GoRouter for navigation

// Mocks essenciais para o fluxo de autenticação
class MockAuthService extends Mock implements AuthService {}
class MockAuthNotifier extends Mock implements AuthNotifier {}

void main() {
  MockAuthService mockAuthService;
  MockAuthNotifier mockAuthNotifier;
  
  // Cria um GoRouter de teste para simular a navegação do app_router.dart
  // Este é um teste de integração que deve simular o roteamento
  late GoRouter router; 

  setUp(() {
    mockAuthService = MockAuthService();
    mockAuthNotifier = MockAuthNotifier();
    
    // Configura o mock notifier para simular o estado inicial (não autenticado)
    when(mockAuthNotifier.isAuthenticated).thenReturn(false); 
    when(mockAuthNotifier.isLoading).thenReturn(false);
    
    // Configura o mock do serviço para simular o sucesso do login
    when(mockAuthService.login(any, any)).thenAnswer((_) async => true);
    
    // Configuração do Router de Teste
    router = GoRouter(
      initialLocation: '/login', // Inicia na tela de Login
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
      ],
      // O RefreshListenable simulará a mudança de estado de autenticação
      refreshListenable: mockAuthNotifier,
      redirect: (BuildContext context, GoRouterState state) {
        final isAuthenticated = mockAuthNotifier.isAuthenticated;
        final isLoggingIn = state.uri.toString() == '/login';

        if (!isAuthenticated) return isLoggingIn ? null : '/login';
        if (isLoggingIn) return '/home';
        return null;
      },
    );
  });
  
  // Helper function para envelopar o widget no ambiente de MultiProvider e GoRouter
  Widget createAuthFlowTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthNotifier>.value(value: mockAuthNotifier),
        // No Teste de Integração, injetamos o Service no Notifier se necessário,
        // mas o Notifier é o que a UI observa. O AuthService é mockado.
      ],
      child: MaterialApp.router(
        routerDelegate: router.routerDelegate,
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
      ),
    );
  }

  group('Auth Flow Integration Test', () {
    testWidgets('Successful login navigates from LoginScreen to HomeScreen', (WidgetTester tester) async {
      // 1. Build the initial widget (LoginScreen)
      await tester.pumpWidget(createAuthFlowTestWidget());
      await tester.pumpAndSettle(); // Renders the LoginScreen

      // Verification: Check if the LoginScreen is visible
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
      
      // 2. Simulate filling the form
      // Assuming keys are used for inputs in LoginScreen
      await tester.enterText(find.byKey(const Key('email_input')), 'test@inovexa.com');
      await tester.enterText(find.byKey(const Key('password_input')), 'securepass123');

      // 3. Mock the internal state change in the Notifier/Service call
      // Quando a UI chama o AuthNotifier.login(), o Notifier internamente chama o AuthService.login().
      // Aqui simulamos que o Notifier chama o Service e, em seguida, atualiza o isAuthenticated para TRUE.
      when(mockAuthNotifier.login(any, any)).thenAnswer((_) async {
        // Simula o sucesso no login e a mudança de estado
        when(mockAuthNotifier.isAuthenticated).thenReturn(true); 
        mockAuthNotifier.notifyListeners(); // Avisa o GoRouter para redirecionar
        return true;
      });

      // 4. Tap the Login button (assuming an 'Login' text on the button)
      await tester.tap(find.text('Login'));
      await tester.pump(); // Inicia a rebuild e o redirecionamento
      await tester.pumpAndSettle(); // Finaliza a animação de navegação/redirecionamento

      // 5. Verification: Check if the navigation succeeded (HomeScreen is visible)
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
      
      // Verification: Check if the AuthService login method was called
      verify(mockAuthNotifier.login(argThat(equals('test@inovexa.com')), argThat(equals('securepass123')))).called(1);
    });

    // Future tests:
    // - testWidgets('Failed login shows error message on LoginScreen')
    // - testWidgets('Auto-redirect to LoginScreen when unauthenticated')
  });
}