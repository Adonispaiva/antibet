import 'package:antibet/core/notifiers/app_config_notifier.dart';
import 'package:antibet/core/notifiers/auth_notifier.dart';
import 'package:antibet/core/notifiers/auth_state_aggregator_notifier.dart';
import 'package:antibet/core/notifiers/bet_journal_notifier.dart';
import 'package:antibet/core/notifiers/connection_notifier.dart';
import 'package:antibet/core/notifiers/financial_metrics_notifier.dart';
import 'package:antibet/core/notifiers/notifications_notifier.dart';
import 'package:antibet/core/notifiers/strategy_notifier.dart';
import 'package:antibet/core/notifiers/user_profile_notifier.dart';
import 'package:antibet/core/notifiers/app_state_aggregator_notifier.dart';
import 'package:antibet/core/services/auth_service.dart';
import 'package:antibet/core/services/config_service.dart';
import 'package:antibet/core/services/journal_service.dart';
import 'package:antibet/core/services/metrics_service.dart';
import 'package:antibet/core/services/notifications_service.dart';
import 'package:antibet/core/services/storage_service.dart';
import 'package:antibet/core/services/strategy_service.dart';
import 'package:antibet/core/services/user_service.dart';
import 'package:antibet/core/services/connectivity_service.dart'; // Pressupondo que este service existe

/// Classe responsável por centralizar a injeção de dependência e
/// garantir que todas as classes (Services e Notifiers) sejam instanciadas
/// corretamente para o uso em todo o aplicativo.
class DependencyInjection {
  // SERVICES (Camada de Dados/Lógica)
  static late final AuthService authService;
  static late final ConfigService configService;
  static late final JournalService journalService;
  static late final MetricsService metricsService;
  static late final NotificationsService notificationsService;
  static late final StorageService storageService;
  static late final StrategyService strategyService;
  static late final UserService userService;
  static late final ConnectivityService connectivityService; // Adicionado para ConnectionNotifier

  // NOTIFIERS (Camada de Estado)
  static late final AuthNotifier authNotifier;
  static late final UserProfileNotifier userProfileNotifier;
  static late final BetJournalNotifier betJournalNotifier;
  static late final FinancialMetricsNotifier financialMetricsNotifier;
  static late final StrategyNotifier strategyNotifier;
  static late final NotificationsNotifier notificationsNotifier;
  static late final AppConfigNotifier appConfigNotifier;
  static late final ConnectionNotifier connectionNotifier;
  
  // NOTIFIERS AGREGADORES
  static late final AuthStateAggregatorNotifier authStateAggregatorNotifier;
  static late final AppStateAggregatorNotifier appStateAggregatorNotifier;


  /// Inicializa todas as instâncias de Services e Notifiers.
  static void initialize() {
    _initializeServices();
    _initializeNotifiers();
    _initializeAggregators();
  }

  /// Instancia todos os Services.
  static void _initializeServices() {
    // Services (não possuem dependências entre si nesta fase inicial)
    storageService = StorageService();
    authService = AuthService(storageService: storageService);
    configService = ConfigService(storageService: storageService);
    journalService = JournalService(storageService: storageService);
    metricsService = MetricsService(journalService: journalService);
    notificationsService = NotificationsService(storageService: storageService);
    strategyService = StrategyService(storageService: storageService);
    userService = UserService(storageService: storageService);
    connectivityService = ConnectivityService();
  }

  /// Instancia todos os Notifiers, injetando Services e/ou outros Notifiers.
  static void _initializeNotifiers() {
    // Notifiers (dependem apenas de Services)
    authNotifier = AuthNotifier(); // Não injeta services por enquanto
    userProfileNotifier = UserProfileNotifier(); 
    betJournalNotifier = BetJournalNotifier();
    financialMetricsNotifier = FinancialMetricsNotifier();
    strategyNotifier = StrategyNotifier();
    notificationsNotifier = NotificationsNotifier();
    appConfigNotifier = AppConfigNotifier();
    connectionNotifier = ConnectionNotifier();
  }

  /// Instancia os Notifiers Agregadores.
  static void _initializeAggregators() {
    // Notifiers Agregadores (dependem de outros Notifiers)
    authStateAggregatorNotifier = AuthStateAggregatorNotifier(
      authNotifier, 
      userProfileNotifier,
    );

    appStateAggregatorNotifier = AppStateAggregatorNotifier(
      authNotifier: authNotifier,
      userProfileNotifier: userProfileNotifier,
      authStateAggregatorNotifier: authStateAggregatorNotifier,
      betJournalNotifier: betJournalNotifier,
      financialMetricsNotifier: financialMetricsNotifier,
      strategyNotifier: strategyNotifier,
      notificationsNotifier: notificationsNotifier,
      appConfigNotifier: appConfigNotifier,
      connectionNotifier: connectionNotifier,
    );
  }
}