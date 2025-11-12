import 'package:antibet_mobile/models/strategy_model.dart';
import 'package:antibet_mobile/screens/add_bet_journal_entry_screen.dart'; // Importação Adicionada
import 'package:antibet_mobile/screens/notifications_screen.dart';
import 'package:antibet_mobile/screens/profile_screen.dart';
import 'package:antibet_mobile/screens/registration/register_screen.dart';
import 'package:antibet_mobile/screens/settings_screen.dart';
import 'package:antibet_mobile/screens/strategy_detail_screen.dart';
import 'package:antibet_mobile/ui/screens/home_screen.dart';
import 'package:antibet_mobile/ui/screens/login_screen.dart';
import 'package:flutter/material.dart';

/// Gerenciador central de rotas (Navegação) para o aplicativo.
class AppRouter {
  // --- Constantes de Rotas ---
  static const String homeRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String strategyDetailRoute = '/strategy-detail';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  static const String notificationsRoute = '/notifications';
  static const String addBetJournalEntryRoute = '/journal/add'; // Rota Adicionada

  /// Gera as rotas com base no [RouteSettings] (nome da rota e argumentos).
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homeRoute:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case registerRoute:
        // (Ajustando o caminho conforme a sua observação)
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case strategyDetailRoute:
        // Extrai os argumentos. Espera-se um StrategyModel.
        final args = settings.arguments;
        if (args is StrategyModel) {
          return MaterialPageRoute(
            builder: (_) => StrategyDetailScreen(strategy: args),
          );
        }
        // Fallback em caso de erro na passagem de argumentos
        return _errorRoute('Argumento StrategyModel inválido ou ausente.');

      case profileRoute:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case settingsRoute:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
        
      case notificationsRoute:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      case addBetJournalEntryRoute: // Rota Adicionada
        return MaterialPageRoute(builder: (_) => const AddBetJournalEntryScreen());

      default:
        // Rota não encontrada
        return _errorRoute('Rota não encontrada: ${settings.name}');
    }
  }

  /// Rota de fallback em caso de erro de navegação.
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Erro de Navegação')),
        body: Center(
          child: Text(message),
        ),
      ),
    );
  }
}