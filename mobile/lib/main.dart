import 'package:antibet_mobile/core/navigation/app_router.dart';
import 'package:antibet_mobile/infra/services/app_config_service.dart';
import 'package:antibet_mobile/infra/services/auth_service.dart';
import 'package:antibet_mobile/infra/services/bet_journal_service.dart';
import 'package:antibet_mobile/infra/services/bet_strategy_service.dart';
import 'package:antibet_mobile/infra/services/dashboard_service.dart';
import 'package:antibet_mobile/infra/services/financial_metrics_service.dart';
import 'package:antibet_mobile/infra/services/push_notification_service.dart';
import 'package:antibet_mobile/infra/services/strategy_recommendation_service.dart'; // Importação Adicionada
import 'package:antibet_mobile/infra/services/storage_service.dart';
import 'package:antibet_mobile/infra/services/user_profile_service.dart';
import 'package:antibet_mobile/notifiers/app_config_notifier.dart';
import 'package:antibet_mobile/notifiers/auth_notifier.dart';
import 'package:antibet_mobile/notifiers/bet_journal_notifier.dart';
import 'package:antibet_mobile/notifiers/bet_strategy_notifier.dart';
import 'package:antibet_mobile/notifiers/dashboard_notifier.dart';
import 'package:antibet_mobile/notifiers/financial_metrics_notifier.dart';
import 'package:antibet_mobile/notifiers/push_notification_notifier.dart';
import 'package:antibet_mobile/notifiers/strategy_recommendation_notifier.dart'; // Importação Adicionada
import 'package:antibet_mobile/notifiers/user_profile_notifier.dart';
import 'package:antibet_mobile/ui/screens/home_screen.dart';
import 'package:antibet_mobile/ui/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // O StorageService (SecureStorage) pode precisar ser inicializado
  // Se for assíncrono, faremos aqui.
  // await StorageService.init(); // Exemplo

  runApp(const AntiBetApp());
}

/// Ponto de entrada principal e Single Source of Truth (SSOT) da arquitetura.
///
/// Define a injeção de dependência (Provider) para todos os Serviços
/// e Notifiers (ViewModels) da aplicação.
class AntiBetApp extends StatelessWidget {
  const AntiBetApp({super.key});

  // 1. Define o tema Escuro (Dark Mode)
  ThemeData get _darkTheme => ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
          // Definir cores específicas do Dark Mode
          primary: Colors.deepPurpleAccent,
          secondary: Colors.tealAccent,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Outras configurações de Dark Mode aqui
      );

  // 2. Define o tema Claro (Light Mode)
  ThemeData get _lightTheme => ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
          // Definir cores específicas do Light Mode
          primary: Colors.deepPurple,
          secondary: Colors.teal,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Outras configurações de Light Mode aqui
      );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // --- PROVEDORES (INJEÇÃO DE DEPENDÊNCIA) ---
      providers: [
        // 1. SERVIÇOS (INFRAESTRUTURA)
        // (Singleton - Camada mais baixa, sem dependências)
        Provider<StorageService>(create: (_) => StorageService()),
        
        // (Serviços que dependem de outros serviços)
        ProxyProvider<StorageService, AuthService>(
          update: (_, storage, __) => AuthService(storage),
        ),
        Provider<UserProfileService>(create: (_) => UserProfileService()),
        Provider<AppConfigService>(create: (_) => AppConfigService()),
        Provider<DashboardService>(create: (_) => DashboardService()),
        Provider<BetStrategyService>(create: (_) => BetStrategyService()),
        Provider<PushNotificationService>(create: (_) => PushNotificationService()), 
        Provider<BetJournalService>(create: (_) => BetJournalService()), 
        Provider<FinancialMetricsService>(create: (_) => FinancialMetricsService()), 
        Provider<StrategyRecommendationService>(create: (_) => StrategyRecommendationService()), // Adicionado

        // 2. NOTIFIERS (GERENCIAMENTO DE ESTADO / VIEWMODELS)
        // (AppConfigProxy: Injeta StorageService)
        ChangeNotifierProxyProvider<StorageService, AppConfigNotifier>(
          create: (context) => AppConfigNotifier(
            context.read<AppConfigService>(),
            context.read<StorageService>(),
          ),
          update: (context, storage, notifier) => AppConfigNotifier(
            context.read<AppConfigService>(),
            storage,
          ),
        ),

        // (AuthNotifier: Injeta AuthService)
        ChangeNotifierProvider<AuthNotifier>(
          create: (context) => AuthNotifier(
            context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider<DashboardNotifier>(
          create: (context) => DashboardNotifier(
            context.read<DashboardService>(),
          ),
        ),
        ChangeNotifierProvider<BetStrategyNotifier>(
          create: (context) => BetStrategyNotifier(
            context.read<BetStrategyService>(),
          ),
        ),
        ChangeNotifierProvider<PushNotificationNotifier>( 
          create: (context) => PushNotificationNotifier(
            context.read<PushNotificationService>(),
          ),
        ),
        ChangeNotifierProvider<BetJournalNotifier>( 
          create: (context) => BetJournalNotifier(
            context.read<BetJournalService>(),
          ),
        ),
        
        // (Proxy Notifier: FinancialMetrics depende de BetJournal)
        ChangeNotifierProxyProvider<BetJournalNotifier, FinancialMetricsNotifier>(
          create: (context) => FinancialMetricsNotifier(
            context.read<FinancialMetricsService>(),
          ),
          update: (context, betJournalNotifier, financialMetricsNotifier) {
            financialMetricsNotifier!.loadMetrics();
            return financialMetricsNotifier;
          },
        ),
        
        // (Proxy Notifier: StrategyRecommendation depende de BetJournal)
        ChangeNotifierProxyProvider<BetJournalNotifier, StrategyRecommendationNotifier>( // Adicionado
          create: (context) => StrategyRecommendationNotifier(
            context.read<StrategyRecommendationService>(),
          ),
          update: (context, betJournalNotifier, recommendationNotifier) {
            // A recomendação é acionada sempre que o histórico muda
            recommendationNotifier!.loadRecommendation();
            return recommendationNotifier;
          },
        ),

        // (Proxy Notifier: UserProfile depende de Auth)
        ChangeNotifierProxyProvider<AuthNotifier, UserProfileNotifier>(
          create: (context) => UserProfileNotifier(
            context.read<UserProfileService>(),
            context.read<AuthNotifier>(),
          ),
          update: (context, authNotifier, userProfileNotifier) {
            userProfileNotifier!.updateUserFromAuth(authNotifier);
            return userProfileNotifier;
          },
        ),
      ],
      // --- FIM DOS PROVEDORES ---
      
      // *** WRAPPER DO CONSUMER PARA TEMA DINÂMICO ***
      child: Consumer<AppConfigNotifier>(
        builder: (context, appConfig, _) {
          return MaterialApp(
            title: 'AntiBet',
            // Define o tema com base no estado do Notifier
            themeMode: appConfig.isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light,
            theme: _lightTheme,
            darkTheme: _darkTheme,
            
            // Define a visualização de acordo com o estado de autenticação
            onGenerateRoute: AppRouter.onGenerateRoute,
            home: Consumer<AuthNotifier>(
              builder: (context, auth, _) {
                switch (auth.status) {
                  case AuthStatus.authenticated:
                    return const HomeScreen(); //
                  case AuthStatus.unauthenticated:
                    return const LoginScreen(); //
                  case AuthStatus.uninitialized:
                  case AuthStatus.loading:
                  default:
                    // Tela de Splash/Loading elegante
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                }
              },
            ),
          );
        },
      ),
      // *** FIM DO WRAPPER DO CONSUMER ***
    );
  }
}