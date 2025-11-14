import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:antibet/core/notifiers/auth_state_aggregator_notifier.dart';
import 'package:antibet/ui/screens/dashboard_screen.dart'; // Pressupondo que a tela existe
import 'package:antibet/ui/screens/home_screen.dart';       // Pressupondo que a tela existe
import 'package:antibet/ui/screens/login_screen.dart';      // Pressupondo que a tela existe

/// Classe que armazena todas as rotas nomeadas do aplicativo.
class AppRoutes {
  // Rotas Nomeadas
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String login = '/login';
  
  // Rota inicial que contém a lógica de checagem de autenticação (Splash/Loading).
  static const String initialRoute = '/';

  // Mapa de rotas do aplicativo.
  static Map<String, WidgetBuilder> get routes => {
        initialRoute: (context) => const AuthCheckerScreen(),
        login: (context) => const LoginScreen(),
        home: (context) => const HomeScreen(),
        dashboard: (context) => const DashboardScreen(),
        // Futuras rotas serão adicionadas aqui (Settings, Profile, etc.)
      };
}

/// Widget que decide qual tela renderizar (Login ou Home) baseado no estado de autenticação.
class AuthCheckerScreen extends StatelessWidget {
  const AuthCheckerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthStateAggregatorNotifier>(context);

    // 1. Enquanto o estado estiver sendo carregado (Splash Screen)
    if (authState.isLoading) {
      // Simulação de uma tela de carregamento simples.
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // 2. Se o carregamento terminou, verifica a autenticação
    if (authState.isAuthenticated) {
      // Se autenticado, vai para a tela principal (Dashboard ou Home).
      return const DashboardScreen();
    } else {
      // Se não autenticado, vai para a tela de Login.
      return const LoginScreen();
    }
  }
}