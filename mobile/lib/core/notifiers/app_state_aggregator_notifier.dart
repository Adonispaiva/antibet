import 'package:flutter/foundation.dart';
import 'package:antibet/core/notifiers/app_config_notifier.dart';
import 'package:antibet/core/notifiers/auth_notifier.dart';
import 'package:antibet/core/notifiers/auth_state_aggregator_notifier.dart';
import 'package:antibet/core/notifiers/bet_journal_notifier.dart';
import 'package:antibet/core/notifiers/connection_notifier.dart';
import 'package:antibet/core/notifiers/financial_metrics_notifier.dart';
import 'package:antibet/core/notifiers/notifications_notifier.dart';
import 'package:antibet/core/notifiers/strategy_notifier.dart';
import 'package:antibet/core/notifiers/user_profile_notifier.dart';

/// O Notifier de nível mais alto, responsável por hospedar e gerenciar
/// o ciclo de vida de todos os Notifiers da aplicação.
/// Ele atua como o Single Source of Truth (SSOT) global.
class AppStateAggregatorNotifier extends ChangeNotifier {
  // Notifiers Autenticação e Perfil
  final AuthNotifier authNotifier;
  final UserProfileNotifier userProfileNotifier;
  final AuthStateAggregatorNotifier authStateAggregatorNotifier;

  // Notifiers Dados do Aplicativo
  final BetJournalNotifier betJournalNotifier;
  final FinancialMetricsNotifier financialMetricsNotifier;
  final StrategyNotifier strategyNotifier;
  final NotificationsNotifier notificationsNotifier;

  // Notifiers Configuração e Infraestrutura
  final AppConfigNotifier appConfigNotifier;
  final ConnectionNotifier connectionNotifier;

  AppStateAggregatorNotifier({
    required this.authNotifier,
    required this.userProfileNotifier,
    required this.authStateAggregatorNotifier,
    required this.betJournalNotifier,
    required this.financialMetricsNotifier,
    required this.strategyNotifier,
    required this.notificationsNotifier,
    required this.appConfigNotifier,
    required this.connectionNotifier,
  });

  /// Método chamado para inicializar o carregamento de dados e verificações
  /// de estado quando o aplicativo é iniciado.
  Future<void> initialize() async {
    // 1. Checagem de Conexão
    await connectionNotifier.checkConnectionStatus();
    
    // 2. Inicialização do estado de Autenticação (checa token, etc.)
    await authStateAggregatorNotifier.initialize();
    
    // Se estiver autenticado, carrega dados principais
    if (authStateAggregatorNotifier.isAuthenticated) {
      await Future.wait([
        userProfileNotifier.loadProfile(authStateAggregatorNotifier.currentUserId),
        // betJournalNotifier.fetchEntries(), // Comentar por enquanto, pois o método não existe
        financialMetricsNotifier.loadInitialMetrics(),
        strategyNotifier.loadStrategies(),
      ]);
    }
    
    // Outras inicializações de dados
    // await appConfigNotifier.loadSettings();
  }

  /// Garante que todos os Notifiers sejam liberados da memória.
  @override
  void dispose() {
    authNotifier.dispose();
    userProfileNotifier.dispose();
    authStateAggregatorNotifier.dispose();
    betJournalNotifier.dispose();
    financialMetricsNotifier.dispose();
    strategyNotifier.dispose();
    notificationsNotifier.dispose();
    appConfigNotifier.dispose();
    connectionNotifier.dispose();
    super.dispose();
  }
}