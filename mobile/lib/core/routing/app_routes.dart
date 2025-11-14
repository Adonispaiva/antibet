import 'package:antibet/core/notifiers/auth_notifier.dart';
import 'package:antibet/mobile/presentation/screens/auth/login_screen.dart';
import 'package:antibet/mobile/presentation/screens/auth/register_screen.dart';
import 'package:antibet/mobile/presentation/screens/config/settings_screen.dart';
import 'package:antibet/mobile/presentation/screens/home_screen.dart';
import 'package:antibet/mobile/presentation/screens/journal/add_bet_journal_entry_screen.dart';
import 'package:antibet/mobile/presentation/screens/notifications/notifications_screen.dart';
import 'package:antibet/mobile/presentation/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Classe renomeada de AppRouter para AppRoutes para manter a coerência interna,
// embora o uso do GoRouter sugira o termo "Router". A preferência do projeto é Routes.
class AppRoutes {
  final AuthNotifier authNotifier;

  AppRoutes(this.authNotifier);

  GoRouter get router => _goRouter;

  late final GoRouter _goRouter = GoRouter(
    // 1. Lógica de Redirecionamento (Guarda de Autenticação)
    refreshListenable: authNotifier,
    
    // 2. Initial Location: Define onde o app começa
    initialLocation: '/login',

    // 3. Definição das Rotas
    routes: <RouteBase>[
      // Rotas de Autenticação
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Rota da Shell Principal
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
        routes: <RouteBase>[
          // Rotas filhas (Detalhes de Estratégia, etc.)
          GoRoute(
            path: 'details/:id', // Exemplo: /home/details/123
            builder: (context, state) {
              final id = state.pathParameters['id'];
              return Text('Details Screen for ID: $id');
            },
          ),
        ],
      ),

      // Rotas de Módulo Secundárias
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/add_bet',
        builder: (context, state) => const AddBetJournalEntryScreen(),
      ),
    ],

    // 4. Implementação do Redirect
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = authNotifier.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      // Se não estiver autenticado e não estiver nas telas de Auth, vá para o login
      if (!isAuthenticated && !isLoggingIn) return '/login'; 
      
      // Se estiver autenticado e tentando acessar telas de Auth, vá para a home
      if (isAuthenticated && isLoggingIn) return '/home'; 
      
      return null; // Caso contrário, continue com a navegação normal
    },
    
    // 5. Tratamento de Erro (Opcional, mas recomendado)
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('404 - Page not found: ${state.error}'),
      ),
    ),
  );
}