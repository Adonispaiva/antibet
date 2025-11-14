// mobile/lib/providers/app_providers.dart

import 'package:antibet/core/services/storage_service.dart';
import 'package:antibet/core/services/auth_service.dart';
import 'package:antibet/core/services/user_service.dart';
import 'package:antibet/core/services/journal_api_service.dart';
import 'package:antibet/core/services/goals_service.dart';
import 'package:antibet/core/services/payments_api_service.dart';
import 'package:antibet/core/services/notifications_service.dart';
import 'package:antibet/core/services/plans_service.dart';
import 'package:antibet/core/services/metrics_service.dart';
import 'package:antibet/core/services/ai_chat_api_service.dart';

import 'package:antibet/features/auth/notifiers/auth_notifier.dart';
import 'package:antibet/features/journal/notifiers/journal_notifier.dart';
import 'package:antibet/features/metrics/notifiers/metrics_notifier.dart';
import 'package:antibet/features/goals/notifiers/goals_notifier.dart';
import 'package:antibet/features/notifications/notifiers/notifications_notifier.dart';
import 'package:antibet/features/payments/notifiers/payments_notifier.dart';
import 'package:antibet/features/ai_chat/notifiers/ai_chat_notifier.dart';

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart'; // Import necessário

// --- DI CONTAINER: SERVICES ---
// Os serviços devem ser criados na ordem das suas dependências.
final List<SingleChildWidget> serviceProviders = [
  // 1. Serviço Base (Não tem dependências)
  Provider<StorageService>(
    create: (_) => StorageService(),
    lazy: false,
  ),

  // 2. Serviços de Autenticação (Depende de StorageService)
  Provider<AuthService>(
    create: (context) => AuthService(
      context.read<StorageService>(),
    ),
  ),
  
  // 3. Serviços que dependem de AuthService/StorageService
  Provider<UserService>(
    create: (context) => UserService(
      context.read<StorageService>(), 
      context.read<AuthService>(),
    ),
  ),
  Provider<JournalApiService>(
    create: (context) => JournalApiService(
      context.read<AuthService>(),
    ),
  ),
  Provider<GoalsService>(
    create: (context) => GoalsService(
      context.read<AuthService>(),
    ),
  ),
  Provider<PaymentsApiService>(
    create: (context) => PaymentsApiService(
      context.read<AuthService>(),
    ),
  ),
  Provider<NotificationsService>(
    create: (context) => NotificationsService(
      context.read<AuthService>(),
    ),
  ),
  Provider<PlansService>(
    create: (context) => PlansService(
      context.read<AuthService>(),
    ),
  ),
  
  // 4. Serviços Complexos
  Provider<JournalNotifier>( // Criado aqui para ser injetado no MetricsService
    create: (context) => JournalNotifier(
      context.read<JournalApiService>(), 
    ),
  ),
  Provider<MetricsService>(
    create: (context) => MetricsService(
      context.read<JournalNotifier>(), // Metrics depende do JournalNotifier para dados
    ),
  ),
  Provider<AiChatApiService>(
    create: (context) => AiChatApiService(
      context.read<AuthService>(),
    ),
  ),
];

// --- DI CONTAINER: NOTIFIERS ---
// Notifiers dependem de Serviços.
final List<SingleChildWidget> notifierProviders = [
  // Auth Notifier (CRÍTICO)
  ChangeNotifierProvider<AuthNotifier>(
    create: (context) => AuthNotifier(
      context.read<AuthService>(),
      context.read<UserService>(),
    )..checkAuthStatus(), 
    lazy: false,
  ),
  
  // Notifiers de Estado
  ChangeNotifierProvider<GoalsNotifier>(
    create: (context) => GoalsNotifier(
      context.read<GoalsService>(),
    ),
  ),
  ChangeNotifierProvider<MetricsNotifier>(
    create: (context) => MetricsNotifier(
      context.read<MetricsService>(),
      context.read<JournalNotifier>(), // MetricsNotifier precisa do JournalNotifier
    ),
  ),
  ChangeNotifierProvider<NotificationsNotifier>(
    create: (context) => NotificationsNotifier(
      context.read<NotificationsService>(),
    ),
  ),
  ChangeNotifierProvider<PaymentsNotifier>(
    create: (context) => PaymentsNotifier(
      context.read<PaymentsApiService>(),
      context.read<PlansService>(),
    ),
  ),
  ChangeNotifierProvider<AiChatNotifier>(
    create: (context) => AiChatNotifier(
      context.read<AiChatApiService>(),
      context.read<AuthNotifier>(),
    ),
  ),
];

// Combina todos os provedores
final List<SingleChildWidget> globalProviders = [
  ...serviceProviders,
  ...notifierProviders,
];