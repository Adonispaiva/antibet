import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Importações dos componentes a serem testados e dependências
import 'package:antibet_mobile/core/navigation/app_router.dart';
import 'package:antibet_mobile/notifiers/auth_notifier.dart';
import 'package:antibet_mobile/notifiers/lockdown_notifier.dart'; // Novo
import 'package:antibet_mobile/presentation/views/home_view.dart';
import 'package:antibet_mobile/presentation/views/login_view.dart';
import 'package:antibet_mobile/presentation/views/help_and_alerts_view.dart'; // Novo

// Gera os mocks para AuthNotifier e LockdownNotifier
@GenerateMocks([AuthNotifier, LockdownNotifier])
import 'app_router_test.mocks.dart';

void main() {
  late MockAuthNotifier mockAuthNotifier;
  late MockLockdownNotifier mockLockdownNotifier; // Novo

  setUp(() {
    mockAuthNotifier = MockAuthNotifier();
    mockLockdownNotifier = MockLockdownNotifier();
    
    // Configuração padrão (sem pânico, não autenticado)
    when(mockLockdownNotifier.isLocked).thenReturn(false);
    when(mockLockdownNotifier.isLoading).thenReturn(false);
    when(mockAuthNotifier.isAuthenticated).thenReturn(false);
  });

  // Wrapper que simula a inicialização do MaterialApp.router
  Widget createRouterApp(GoRouter router) {
    return MaterialApp.router(
      routerConfig: router,
    );
  }

  // --- Testes de Autenticação (Existentes) ---
  group('AppRouter AuthGuard Tests', () {
    // ... (Testes anteriores de autenticação omitidos por brevidade) ...
  });

  // --- Testes do Botão de Pânico (Novos) ---
  group('AppRouter Lockdown Guard Tests (Missão Anti-Vício)', () {
    
    // --- Teste 1: Bloqueado, tentando acessar Home ---
    testWidgets('Redireciona para /home/help se isLocked=true e tentar acessar /home', (WidgetTester tester) async {
      // Configuração: Pânico Ativo, Usuário Autenticado
      when(mockLockdownNotifier.isLocked).thenReturn(true);
      when(mockAuthNotifier.isAuthenticated).thenReturn(true);
      
      final router = AppRouter(mockAuthNotifier, mockLockdownNotifier).router;

      await tester.pumpWidget(createRouterApp(router));
      
      // Tenta navegar para a Home (rota protegida)
      router.setInitialLocation('/home');
      await tester.pumpAndSettle();

      // Deve ser FORÇADO para a tela de Ajuda
      expect(find.byType(HelpAndAlertsView), findsOneWidget);
      expect(find.byType(HomeView), findsNothing);
      expect(router.location, '/home/help');
    });

    // --- Teste 2: Bloqueado, tentando acessar Login ---
    testWidgets('Redireciona para /home/help se isLocked=true e tentar acessar /login', (WidgetTester tester) async {
      // Configuração: Pânico Ativo, Usuário Não Autenticado
      when(mockLockdownNotifier.isLocked).thenReturn(true);
      when(mockAuthNotifier.isAuthenticated).thenReturn(false);
      
      final router = AppRouter(mockAuthNotifier, mockLockdownNotifier).router;
      await tester.pumpWidget(createRouterApp(router));
      
      // Tenta navegar para o Login
      router.setInitialLocation('/login');
      await tester.pumpAndSettle();

      // Deve ser FORÇADO para a tela de Ajuda
      expect(find.byType(HelpAndAlertsView), findsOneWidget);
      expect(find.byType(LoginView), findsNothing);
      expect(router.location, '/home/help');
    });
    
    // --- Teste 3: Bloqueado, mas já na tela de Ajuda ---
    testWidgets('Permite ficar em /home/help se isLocked=true', (WidgetTester tester) async {
      // Configuração: Pânico Ativo
      when(mockLockdownNotifier.isLocked).thenReturn(true);
      when(mockAuthNotifier.isAuthenticated).thenReturn(true); // Autenticado
      
      final router = AppRouter(mockAuthNotifier, mockLockdownNotifier).router;
      await tester.pumpWidget(createRouterApp(router));
      
      // Tenta navegar para a Ajuda
      router.setInitialLocation('/home/help');
      await tester.pumpAndSettle();

      // Deve permanecer na Ajuda (evita loop de redirecionamento)
      expect(find.byType(HelpAndAlertsView), findsOneWidget);
      expect(router.location, '/home/help');
    });
  });
}