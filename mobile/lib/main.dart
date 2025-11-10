import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http; // Novo: Para o cliente HTTP do Detector

// Importações das camadas de Arquitetura
import 'core/navigation/app_router.dart';
import 'infra/services/storage_service.dart';
import 'infra/services/auth_service.dart';
import 'infra/services/user_profile_service.dart';
import 'infra/services/app_config_service.dart';
import 'infra/services/dashboard_service.dart'; 
import 'infra/services/bet_strategy_service.dart';
import 'infra/services/help_and_alerts_service.dart';
import 'infra/services/lockdown_service.dart';
import 'infra/services/behavioral_analytics_service.dart'; 
import 'infra/services/advertorial_detector_service.dart'; // NOVO: Serviço de Detecção

import 'notifiers/auth_notifier.dart';
import 'notifiers/user_profile_notifier.dart';
import 'notifiers/app_config_notifier.dart';
import 'notifiers/dashboard_notifier.dart';
import 'notifiers/bet_strategy_notifier.dart';
import 'notifiers/help_and_alerts_notifier.dart';
import 'notifiers/lockdown_notifier.dart';
import 'notifiers/behavioral_analytics_notifier.dart'; 
import 'notifiers/advertorial_detector_notifier.dart'; // NOVO: Notifier do Detector (Card 3)


void main() async {
  // Garante que o Flutter esteja inicializado antes de acessar plugins
  WidgetsFlutterBinding.ensureInitialized();
  
  // URL Base para o Backend (IMPORTANTE: Mude esta URL em Produção)
  const String advertorialBaseUrl = 'http://localhost:8000/api/v1'; 

  // 1. Inicialização do StorageService (base de segurança)
  final StorageService storageService = StorageService(); 
  
  // 2. Inicialização dos Services de Infraestrutura
  final AuthService authService = AuthService(storageService);
  final UserProfileService userProfileService = UserProfileService();
  final AppConfigService appConfigService = AppConfigService();
  final DashboardService dashboardService = DashboardService();
  final BetStrategyService betStrategyService = BetStrategyService();
  final HelpAndAlertsService helpAndAlertsService = HelpAndAlertsService();
  final LockdownService lockdownService = LockdownService();
  final BehavioralAnalyticsService behavioralAnalyticsService = BehavioralAnalyticsService(); 
  
  // NOVO: Serviço do Detector de Advertorial (Injetando o cliente HTTP)
  final AdvertorialDetectorService advertorialDetectorService = AdvertorialDetectorService(
    baseUrl: advertorialBaseUrl,
    httpClient: http.Client(),
  );

  // 3. Inicialização dos Notifiers (Estado)
  final AuthNotifier authNotifier = AuthNotifier(authService);
  final AppConfigNotifier appConfigNotifier = AppConfigNotifier(appConfigService); 
  final DashboardNotifier dashboardNotifier = DashboardNotifier(dashboardService);
  final BetStrategyNotifier betStrategyNotifier = BetStrategyNotifier(betStrategyService);
  final HelpAndAlertsNotifier helpAndAlertsNotifier = HelpAndAlertsNotifier(helpAndAlertsService);
  final LockdownNotifier lockdownNotifier = LockdownNotifier(lockdownService);
  final BehavioralAnalyticsNotifier behavioralAnalyticsNotifier = BehavioralAnalyticsNotifier(behavioralAnalyticsService); 
  
  // NOVO: Notifier do Detector (Injetando o serviço)
  final AdvertorialDetectorNotifier advertorialDetectorNotifier = AdvertorialDetectorNotifier(
    detectorService: advertorialDetectorService,
  );

  // 4. Injeção de Dependência Cruzada (Late-Binding) para Analytics
  authNotifier.setAnalyticsNotifier(behavioralAnalyticsNotifier);
  lockdownNotifier.setAnalyticsNotifier(behavioralAnalyticsNotifier);

  // 5. Carregamento Assíncrono na Inicialização (Prioridade)
  await Future.wait([
    authNotifier.checkAuthenticationStatus(), 
    appConfigNotifier.loadConfig(), 
    dashboardNotifier.fetchDashboardContent(), 
    helpAndAlertsNotifier.fetchResources(),
    lockdownNotifier.checkLockdownStatus(), 
    behavioralAnalyticsNotifier.calculateAnalytics(), 
  ]);

  // 6. Inicialização dos Notifiers Dependentes
  final UserProfileNotifier userProfileNotifier = UserProfileNotifier(
    userProfileService,
    authNotifier, 
  );
  
  // 7. Inicialização do AppRouter
  final AppRouter appRouter = AppRouter(authNotifier, lockdownNotifier); 
  
  runApp(
    // Usa MultiProvider para injetar múltiplos Notifiers
    MultiProvider(
      providers: [
        // Notifiers independentes
        ChangeNotifierProvider<AuthNotifier>.value(value: authNotifier),
        ChangeNotifierProvider<AppConfigNotifier>.value(value: appConfigNotifier),
        ChangeNotifierProvider<DashboardNotifier>.value(value: dashboardNotifier),
        ChangeNotifierProvider<BetStrategyNotifier>.value(value: betStrategyNotifier),
        ChangeNotifierProvider<HelpAndAlertsNotifier>.value(value: helpAndAlertsNotifier),
        ChangeNotifierProvider<LockdownNotifier>.value(value: lockdownNotifier),
        ChangeNotifierProvider<BehavioralAnalyticsNotifier>.value(value: behavioralAnalyticsNotifier),
        
        // NOVO: Notifier do Detector (Card 3)
        ChangeNotifierProvider<AdvertorialDetectorNotifier>.value(value: advertorialDetectorNotifier),

        // Services para o caso de consumo direto por um Widget/Service
        Provider<AdvertorialDetectorService>.value(value: advertorialDetectorService),
        
        // Notifiers dependentes
        ChangeNotifierProvider<UserProfileNotifier>.value(value: userProfileNotifier),
      ],
      child: AntiBetMobileApp(appRouter: appRouter),
    ),
  );
}

class AntiBetMobileApp extends StatelessWidget {
  final AppRouter appRouter;
  
  const AntiBetMobileApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    // Escuta o AppConfigNotifier para reagir a mudanças no tema
    final configNotifier = context.watch<AppConfigNotifier>();

    return MaterialApp.router(
      title: 'AntiBet Mobile',
      
      // Define o modo de tema baseado na configuração do usuário
      themeMode: configNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // Tema Claro Padrão
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      
      // Tema Escuro (Dark Theme)
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        // Configurações básicas do tema escuro para contraste
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[850],
        ),
      ),

      // Configuração do Router
      routerConfig: appRouter.router,
    );
  }
}