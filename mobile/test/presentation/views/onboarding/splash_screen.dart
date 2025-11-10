import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:antibet/src/core/notifiers/auth_notifier.dart';
import 'package:antibet/src/core/notifiers/app_config_notifier.dart';
import 'package:antibet/src/presentation/views/onboarding/splash_screen.dart';

// Constante para a chave de consentimento
const String _consentKey = 'user_accepted_consent';

// Mocks
class MockAuthNotifier extends Mock implements AuthNotifier {
  @override
  bool get isLoggedIn => super.noSuchMethod(
        Invocation.getter(#isLoggedIn),
        returnValue: false,
      ) as bool;
  @override
  Future<void> checkAuthenticationStatus() => super.noSuchMethod(
        Invocation.method(#checkAuthenticationStatus, []),
        returnValue: Future.value(null),
      ) as Future<void>;
}

class MockAppConfigNotifier extends Mock implements AppConfigNotifier {
  @override
  Future<void> loadConfig() => super.noSuchMethod(
        Invocation.method(#loadConfig, []),
        returnValue: Future.value(null),
      ) as Future<void>;
}

// Helper para o AppRouter (necessário para testar a navegação)
class MockGoRouterProvider extends StatelessWidget {
  const MockGoRouterProvider({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Configura um GoRouter com rotas de destino simuladas
    return GoRouter(
      initialLocation: '/', // Inicia na splash
      routes: [
        GoRoute(path: '/', builder: (context, state) => child),
        GoRoute(path: '/consent', builder: (context, state) => const Text('Consent Screen')),
        GoRoute(path: '/register', builder: (context, state) => const Text('Register Screen')),
        GoRoute(path: '/home', builder: (context, state) => const Text('Home Screen')),
      ],
    ).createRouterWidget(context);
  }
}

Widget createWidgetUnderTest(MockAuthNotifier mockAuth, MockAppConfigNotifier mockConfig) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthNotifier>.value(value: mockAuth),
      ChangeNotifierProvider<AppConfigNotifier>.value(value: mockConfig),
    ],
    child: MockGoRouterProvider(
      child: const SplashScreen(),
    ),
  );
}

void main() {
  late MockAuthNotifier mockAuth;
  late MockAppConfigNotifier mockConfig;

  setUp(() {
    mockAuth = MockAuthNotifier();
    mockConfig = MockAppConfigNotifier();
  });

  group('SplashScreen Widget Tests - Roteamento Condicional', () {
    testWidgets('Roteia para /consent se o consentimento não foi aceito', (WidgetTester tester) async {
      // Setup: Consentimento NÃO aceito (default) e NÃO logado (default)
      SharedPreferences.setMockInitialValues({_consentKey: false});
      when(mockAuth.isLoggedIn).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest(mockAuth, mockConfig));
      await tester.pumpAndSettle(const Duration(seconds: 3)); // Espera o Future.wait + delay

      // Verifica se a tela de Consentimento foi carregada
      expect(find.text('Consent Screen'), findsOneWidget);
      verify(mockAuth.checkAuthenticationStatus()).called(1);
    });

    testWidgets('Roteia para /register se o consentimento foi aceito mas NÃO está logado', (WidgetTester tester) async {
      // Setup: Consentimento ACEITO e NÃO logado
      SharedPreferences.setMockInitialValues({_consentKey: true});
      when(mockAuth.isLoggedIn).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest(mockAuth, mockConfig));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verifica se a tela de Cadastro/Registro foi carregada
      expect(find.text('Register Screen'), findsOneWidget);
      verify(mockAuth.checkAuthenticationStatus()).called(1);
    });

    testWidgets('Roteia para /home se o consentimento foi aceito E está logado', (WidgetTester tester) async {
      // Setup: Consentimento ACEITO e Logado
      SharedPreferences.setMockInitialValues({_consentKey: true});
      when(mockAuth.isLoggedIn).thenReturn(true);

      await tester.pumpWidget(createWidgetUnderTest(mockAuth, mockConfig));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verifica se a tela Home foi carregada
      expect(find.text('Home Screen'), findsOneWidget);
      verify(mockAuth.checkAuthenticationStatus()).called(1);
    });

    testWidgets('Deve exibir o logo e slogan durante o carregamento', (WidgetTester tester) async {
      // Configura um tempo longo no Future para testar a exibição
      when(mockAuth.checkAuthenticationStatus()).thenAnswer((_) => Future.delayed(const Duration(seconds: 5)));
      
      await tester.pumpWidget(createWidgetUnderTest(mockAuth, mockConfig));
      
      // Verifica a presença dos elementos visuais antes da transição
      expect(find.text('IA mudando vidas.'), findsOneWidget); //
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Inovexa Software'), findsOneWidget); //
      
      // Não deve ter navegado ainda
      expect(find.text('Consent Screen'), findsNothing);
    });
  });
}