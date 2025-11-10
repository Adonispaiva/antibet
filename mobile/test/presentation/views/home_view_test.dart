import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Importações dos componentes a serem testados e dependências
import 'package:antibet_mobile/core/domain/dashboard_content_model.dart';
import 'package:antibet_mobile/core/domain/user_model.dart';
import 'package:antibet_mobile/notifiers/auth_notifier.dart';
import 'package:antibet_mobile/notifiers/dashboard_notifier.dart';
import 'package:antibet_mobile/notifiers/lockdown_notifier.dart'; // Novo
import 'package:antibet_mobile/notifiers/help_and_alerts_notifier.dart'; // Novo
import 'package:antibet_mobile/presentation/views/home_view.dart';
import 'package:antibet_mobile/core/navigation/app_router.dart'; 

// Gera os mocks para as dependências
@GenerateMocks([AuthNotifier, DashboardNotifier, LockdownNotifier, HelpAndAlertsNotifier]) // Atualizado
import 'home_view_test.mocks.dart'; 

// Cria um Router simples para simular a navegação
final GoRouter mockRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/home',
      name: AppRoute.home.name,
      builder: (context, state) => const HomeView(),
      routes: [
        GoRoute(path: 'profile', name: AppRoute.profile.name, builder: (context, state) => const Placeholder()),
        GoRoute(path: 'settings', name: AppRoute.settings.name, builder: (context, state) => const Placeholder()),
        GoRoute(path: 'strategies', name: AppRoute.strategies.name, builder: (context, state) => const Placeholder()),
        GoRoute(path: 'help', name: AppRoute.help.name, builder: (context, state) => const Placeholder()),
      ],
    ),
  ],
  initialLocation: '/home',
);

// Wrapper que simula o ambiente da aplicação com MultiProvider
Widget createHomeScreenWrapper({
  required AuthNotifier authNotifier,
  required DashboardNotifier dashboardNotifier,
  required LockdownNotifier lockdownNotifier,
  required HelpAndAlertsNotifier helpAndAlertsNotifier,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthNotifier>.value(value: authNotifier),
      ChangeNotifierProvider<DashboardNotifier>.value(value: dashboardNotifier),
      ChangeNotifierProvider<LockdownNotifier>.value(value: lockdownNotifier),
      ChangeNotifierProvider<HelpAndAlertsNotifier>.value(value: helpAndAlertsNotifier),
    ],
    child: MaterialApp.router(
      routerConfig: mockRouter,
    ),
  );
}

void main() {
  late MockAuthNotifier mockAuthNotifier;
  late MockDashboardNotifier mockDashboardNotifier;
  late MockLockdownNotifier mockLockdownNotifier;
  late MockHelpAndAlertsNotifier mockHelpAndAlertsNotifier;

  const UserModel testUser = UserModel(id: '1', email: 'orion@inovexa.com.br');
  const DashboardContentModel testContent = DashboardContentModel(
    totalBetsAnalyzed: 999,
    recentActivityTitle: 'Nova análise de dados recebida.',
    currentBalance: 123.45,
  );

  setUp(() {
    mockAuthNotifier = MockAuthNotifier();
    mockDashboardNotifier = MockDashboardNotifier();
    mockLockdownNotifier = MockLockdownNotifier();
    mockHelpAndAlertsNotifier = MockHelpAndAlertsNotifier();
    
    // Configuração do AuthNotifier
    when(mockAuthNotifier.currentUser).thenReturn(testUser);
    
    // Configuração do Dashboard (Estado Carregado)
    when(mockDashboardNotifier.state).thenReturn(DashboardState.loaded);
    when(mockDashboardNotifier.content).thenReturn(testContent);
    
    // Configuração dos Notifiers de Pânico/Ajuda
    when(mockHelpAndAlertsNotifier.triggerAlert(any)).thenAnswer((_) async {});
    when(mockLockdownNotifier.activateLockdown(any)).thenAnswer((_) async {});
  });

  // Testes de Dashboard (Loading, Error, Loaded) ...
  // ... (Testes anteriores omitidos por brevidade) ...

  group('HomeView - Panic Button (Missão Anti-Vício)', () {
    
    Finder findPanicButton() => find.widgetWithText(ElevatedButton, 'BLOQUEIO DE PÂNICO');

    // --- Teste 1: Confirmação e Ativação ---
    testWidgets('Tocar no Botão de Pânico exibe AlertDialog e ativa o bloqueio', (WidgetTester tester) async {
      
      await tester.pumpWidget(createHomeScreenWrapper(
        authNotifier: mockAuthNotifier,
        dashboardNotifier: mockDashboardNotifier,
        lockdownNotifier: mockLockdownNotifier,
        helpAndAlertsNotifier: mockHelpAndAlertsNotifier,
      ));
      
      // 1. Encontra o botão de pânico
      expect(findPanicButton(), findsOneWidget);
      
      // 2. Toca no botão
      await tester.tap(findPanicButton());
      await tester.pumpAndSettle(); // Aguarda o AlertDialog abrir
      
      // 3. Verifica o diálogo de confirmação
      expect(find.text('⚠️ ATIVAR BLOQUEIO DE EMERGÊNCIA?'), findsOneWidget);
      expect(find.text('ATIVAR BLOQUEIO'), findsOneWidget);
      
      // 4. Toca em "ATIVAR BLOQUEIO"
      await tester.tap(find.text('ATIVAR BLOQUEIO'));
      await tester.pumpAndSettle(); // Aguarda o diálogo fechar e os notifiers serem chamados
      
      // 5. Verifica se os notifiers corretos foram chamados
      verify(mockHelpAndAlertsNotifier.triggerAlert('Botão de Pânico (SOS) Ativado')).called(1);
      verify(mockLockdownNotifier.activateLockdown(const Duration(hours: 24))).called(1);
    });
    
    // --- Teste 2: Cancelamento do Diálogo ---
    testWidgets('Cancelar o AlertDialog não ativa o bloqueio', (WidgetTester tester) async {
      
      await tester.pumpWidget(createHomeScreenWrapper(
        authNotifier: mockAuthNotifier,
        dashboardNotifier: mockDashboardNotifier,
        lockdownNotifier: mockLockdownNotifier,
        helpAndAlertsNotifier: mockHelpAndAlertsNotifier,
      ));
      
      await tester.tap(findPanicButton());
      await tester.pumpAndSettle(); 
      
      // Toca em "Cancelar"
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle(); 
      
      // Verifica que os notifiers NUNCA foram chamados
      verifyNever(mockHelpAndAlertsNotifier.triggerAlert(any));
      verifyNever(mockLockdownNotifier.activateLockdown(any));
    });
  });
}