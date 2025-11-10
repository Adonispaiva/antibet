import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Importações dos Notifiers (para lógica de proteção)
import 'package:antibet_app/notifiers/auth_notifier.dart';
import 'package:antibet_app/notifiers/lockdown_notifier.dart';

// Importações das Telas (Simuladas - Telas Reais devem ser criadas)
import 'package:antibet_app/screens/login_screen.dart'; // Tela de Login
import 'package:antibet_app/screens/home_screen.dart';   // Tela principal (Dashboard)
import 'package:antibet_app/screens/lockdown_screen.dart'; // Tela de Bloqueio
import 'package:antibet_app/screens/browser_screen.dart'; // Tela do Navegador

// Definição das rotas nomeadas
class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String lockdown = '/lockdown';
  static const String browser = '/browser';
}

class AppRouter {
  final AuthNotifier _authNotifier;
  final LockdownNotifier _lockdownNotifier;
  late final GoRouter router;

  AppRouter(this._authNotifier, this._lockdownNotifier) {
    router = GoRouter(
      // Lista inicial de URLs, para evitar tela branca em testes
      initialLocation: AppRoutes.login, 
      
      // Chave essencial para acessar o BuilderContext para o Provider/watch
      refreshListenable: Listenable.merge([_authNotifier, _lockdownNotifier]), 
      
      // Lógica de Redirecionamento de Proteção
      redirect: (BuildContext context, GoRouterState state) {
        final authNotifier = context.read<AuthNotifier>();
        final lockdownNotifier = context.read<LockdownNotifier>();

        final bool isAuthenticated = authNotifier.isAuthenticated;
        final bool isInLockdown = lockdownNotifier.isInLockdown;
        final bool isGoingToLogin = state.matchedLocation == AppRoutes.login;
        final bool isGoingToLockdown = state.matchedLocation == AppRoutes.lockdown;

        // 1. Não autenticado: Se não estiver logado, redireciona para Login.
        if (!isAuthenticated) {
          return isGoingToLogin ? null : AppRoutes.login; // Permite Login, bloqueia outras
        }
        
        // 2. Em Lockdown: Se estiver logado E em Lockdown, redireciona para Lockdown.
        if (isInLockdown) {
          return isGoingToLockdown ? null : AppRoutes.lockdown; // Permite Lockdown, bloqueia outras
        }
        
        // 3. Autenticado e Livre: Se estiver logado e NÃO em Lockdown.
        // Se estiver tentando ir para Login ou Lockdown, redireciona para Home.
        if (isGoingToLogin || isGoingToLockdown) {
          return AppRoutes.home;
        }

        // Não há redirecionamento necessário
        return null;
      },
      
      // Definição das Rotas
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.lockdown,
          builder: (context, state) => const LockdownScreen(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomeScreen(), // Ex: Tela principal com navegação
          routes: [
            GoRoute(
              path: 'browser', // Rota completa: /home/browser
              name: AppRoutes.browser,
              builder: (context, state) => const BrowserScreen(),
            ),
          ],
        ),
      ],
      
      // Configuração de erro (opcional, mas recomendado)
      errorBuilder: (context, state) => const Scaffold(
        body: Center(child: Text("Erro 404: Rota não encontrada")),
      ),
    );
  }
}