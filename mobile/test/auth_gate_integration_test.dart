import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Importações dos componentes a serem testados e dependências
import 'package:antibet_mobile/notifiers/auth_notifier.dart';
import 'package:antibet_mobile/presentation/views/home_view.dart';
import 'package:antibet_mobile/presentation/views/login_view.dart';
import 'package:antibet_mobile/main.dart'; // Importa AntiBetMobileApp e AuthGate

// Gera o mock para o AuthNotifier (pois é o que o AuthGate consome)
@GenerateMocks([AuthNotifier])
import 'auth_gate_integration_test.mocks.dart';

void main() {
  late MockAuthNotifier mockAuthNotifier;

  setUp(() {
    mockAuthNotifier = MockAuthNotifier();
  });

  // Wrapper que simula a inicialização da aplicação para o teste
  Widget createTestableApp({required AuthNotifier notifier}) {
    return ChangeNotifierProvider<AuthNotifier>.value(
      value: notifier,
      child: const AntiBetMobileApp(), // Testamos a App raiz
    );
  }

  group('AuthGate Integration Tests', () {
    // --- Teste 1: Estado Inicial (Loading) ---
    testWidgets('App exibe CircularProgressIndicator no estado inicial/loading', (WidgetTester tester) async {
      // Configuração: Estado inicial do Notifier é Loading
      when(mockAuthNotifier.state).thenReturn(AuthState.loading);

      await tester.pumpWidget(createTestableApp(notifier: mockAuthNotifier));
      
      // O AuthGate deve mostrar o indicador de carregamento
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(LoginView), findsNothing);
      expect(find.byType(HomeView), findsNothing);
    });

    // --- Teste 2: Estado Não Autenticado (LoginView) ---
    testWidgets('App navega para LoginView quando não autenticado', (WidgetTester tester) async {
      // Configuração: Notifier é unauthenticated
      when(mockAuthNotifier.state).thenReturn(AuthState.unauthenticated);

      // Simula a inicialização da aplicação (pump é usado apenas para construir)
      await tester.pumpWidget(createTestableApp(notifier: mockAuthNotifier));
      
      // O AuthGate deve mostrar a LoginView
      expect(find.byType(LoginView), findsOneWidget);
      expect(find.text('Login - AntiBet Mobile'), findsOneWidget);
      expect(find.byType(HomeView), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    // --- Teste 3: Estado Autenticado (HomeView) ---
    testWidgets('App navega para HomeView quando autenticado', (WidgetTester tester) async {
      // Configuração: Notifier é authenticated
      when(mockAuthNotifier.state).thenReturn(AuthState.authenticated);

      await tester.pumpWidget(createTestableApp(notifier: mockAuthNotifier));

      // O AuthGate deve mostrar a HomeView
      expect(find.byType(HomeView), findsOneWidget);
      // HomeView tem um título padrão "Home Screen - AntiBet Mobile"
      expect(find.text('Home Screen - AntiBet Mobile'), findsOneWidget); 
      expect(find.byType(LoginView), findsNothing);
    });

    // --- Teste 4: Transição de Estado (Logout) ---
    testWidgets('Transição de authenticated para unauthenticated volta para LoginView', (WidgetTester tester) async {
      // 1. Início: Configura como autenticado
      when(mockAuthNotifier.state).thenReturn(AuthState.authenticated);
      await tester.pumpWidget(createTestableApp(notifier: mockAuthNotifier));
      expect(find.byType(HomeView), findsOneWidget);

      // 2. Transição: Simula o logout mudando o estado do Notifier
      when(mockAuthNotifier.state).thenReturn(AuthState.unauthenticated);
      
      // Notifica os listeners (como o AuthGate)
      mockAuthNotifier.notifyListeners(); 
      await tester.pumpAndSettle(); // Aguarda a reconstrução

      // 3. Verifica o estado final
      expect(find.byType(LoginView), findsOneWidget);
      expect(find.byType(HomeView), findsNothing);
    });

    // --- Teste 5: Transição de Estado (Login) ---
    testWidgets('Transição de unauthenticated para authenticated vai para HomeView', (WidgetTester tester) async {
      // 1. Início: Configura como não autenticado
      when(mockAuthNotifier.state).thenReturn(AuthState.unauthenticated);
      await tester.pumpWidget(createTestableApp(notifier: mockAuthNotifier));
      expect(find.byType(LoginView), findsOneWidget);

      // 2. Transição: Simula o login mudando o estado do Notifier
      when(mockAuthNotifier.state).thenReturn(AuthState.authenticated);
      
      // Notifica os listeners
      mockAuthNotifier.notifyListeners(); 
      await tester.pumpAndSettle(); 

      // 3. Verifica o estado final
      expect(find.byType(HomeView), findsOneWidget);
      expect(find.byType(LoginView), findsNothing);
    });
  });
}