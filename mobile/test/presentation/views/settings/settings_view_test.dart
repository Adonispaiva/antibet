import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:go_router/go_router.dart';

import 'package:antibet/src/core/notifiers/app_config_notifier.dart';
import 'package:antibet/src/core/notifiers/auth_notifier.dart';
import 'package:antibet/src/presentation/views/settings/settings_view.dart';

// Mocks
class MockAppConfigNotifier extends Mock implements AppConfigNotifier {
  @override
  bool get isDarkMode => super.noSuchMethod(
        Invocation.getter(#isDarkMode),
        returnValue: false,
      ) as bool;
  @override
  Future<void> toggleDarkMode(bool newValue) => super.noSuchMethod(
        Invocation.method(#toggleDarkMode, [newValue]),
        returnValue: Future.value(null),
      ) as Future<void>;
  @override
  void addListener(VoidCallback listener) => super.noSuchMethod(Invocation.method(#addListener, [listener]), returnValue: null);
  @override
  void removeListener(VoidCallback listener) => super.noSuchMethod(Invocation.method(#removeListener, [listener]), returnValue: null);
}

class MockAuthNotifier extends Mock implements AuthNotifier {
  @override
  Future<void> logout() => super.noSuchMethod(
        Invocation.method(#logout, []),
        returnValue: Future.value(null),
      ) as Future<void>;
  @override
  void addListener(VoidCallback listener) => super.noSuchMethod(Invocation.method(#addListener, [listener]), returnValue: null);
  @override
  void removeListener(VoidCallback listener) => super.noSuchMethod(Invocation.method(#removeListener, [listener]), returnValue: null);
}

// Helper para o AppRouter (necessário para testar context.go)
class MockGoRouterProvider extends StatelessWidget {
  const MockGoRouterProvider({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Configura um GoRouter com rotas de destino simuladas
    return GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => child), // Tela sob teste
        GoRoute(path: '/login', builder: (context, state) => const Text('Login Screen')),
        GoRoute(path: '/settings/change-password', builder: (context, state) => const Text('Change Password Screen')),
        GoRoute(path: '/settings/data-management', builder: (context, state) => const Text('Data Management Screen')),
      ],
    ).createRouterWidget(context);
  }
}

Widget createWidgetUnderTest(MockAppConfigNotifier mockConfig, MockAuthNotifier mockAuth) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AppConfigNotifier>.value(value: mockConfig),
      ChangeNotifierProvider<AuthNotifier>.value(value: mockAuth),
    ],
    child: MockGoRouterProvider(
      child: const SettingsView(),
    ),
  );
}

void main() {
  late MockAppConfigNotifier mockConfig;
  late MockAuthNotifier mockAuth;

  setUp(() {
    mockConfig = MockAppConfigNotifier();
    mockAuth = MockAuthNotifier();
  });

  group('SettingsView Widget Tests', () {
    testWidgets('Toggle Dark Mode should call toggleDarkMode on AppConfigNotifier', (WidgetTester tester) async {
      // Setup: Mocka o estado inicial para false
      when(mockConfig.isDarkMode).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest(mockConfig, mockAuth));

      // 1. Encontra o SwitchListTile
      final darkModeSwitch = find.widgetWithText(SwitchListTile, 'Modo Escuro (Dark Mode)');
      expect(darkModeSwitch, findsOneWidget);

      // 2. Ação: Tocar no switch
      await tester.tap(darkModeSwitch);
      await tester.pump();

      // Verificação: O método toggleDarkMode deve ser chamado com true
      verify(mockConfig.toggleDarkMode(true)).called(1);
    });

    testWidgets('Logout tile should call logout on AuthNotifier and navigate', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(mockConfig, mockAuth));

      // 1. Encontra o tile de Logout
      final logoutTile = find.widgetWithText(ListTile, 'Sair da Conta (Logout)');
      expect(logoutTile, findsOneWidget);

      // 2. Ação: Tocar no tile
      await tester.tap(logoutTile);
      await tester.pumpAndSettle();

      // Verificação 1: O método logout deve ser chamado
      verify(mockAuth.logout()).called(1);

      // Verificação 2: Deve navegar para a tela de Login
      expect(find.text('Login Screen'), findsOneWidget);
    });
    
    testWidgets('Tapping Declaração Ética should show the AlertDialog', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(mockConfig, mockAuth));

      // 1. Encontra o tile de Declaração Ética
      final ethicalTile = find.widgetWithText(ListTile, 'Declaração Ética (LGPD/Saúde)');
      expect(ethicalTile, findsOneWidget);

      // 2. Ação: Tocar no tile
      await tester.tap(ethicalTile);
      await tester.pumpAndSettle(); // Espera o showDialog

      // Verificação 1: O AlertDialog deve ser exibido
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Declaração Ética e de Compliance'), findsOneWidget);
      expect(find.textContaining('O AntiBet NÃO é um substituto para terapia clínica'), findsOneWidget);
      
      // 3. Fecha o diálogo
      await tester.tap(find.text('Entendi'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });
    
    testWidgets('Tapping Change Password should navigate to change-password route', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(mockConfig, mockAuth));

      final changePassTile = find.widgetWithText(ListTile, 'Alterar Senha');
      await tester.tap(changePassTile);
      await tester.pumpAndSettle();
      
      expect(find.text('Change Password Screen'), findsOneWidget);
    });

    testWidgets('Tapping Gerenciar Dados Pessoais should navigate to data-management route', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(mockConfig, mockAuth));

      final dataMgmtTile = find.widgetWithText(ListTile, 'Gerenciar Dados Pessoais');
      await tester.tap(dataMgmtTile);
      await tester.pumpAndSettle();
      
      expect(find.text('Data Management Screen'), findsOneWidget);
    });
  });
}