import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antibet/features/auth/presentation/screens/login_screen.dart';
import 'package:antibet/features/auth/presentation/screens/register_screen.dart';
import 'package:antibet/features/journal/presentation/screens/journal_screen.dart';
import 'package:antibet/features/journal/presentation/screens/add_entry_screen.dart';
import 'package:antibet/features/journal/presentation/screens/edit_entry_screen.dart';
import 'package:antibet/features/settings/presentation/screens/settings_screen.dart'; // NOVO IMPORT
import 'package:antibet/features/journal/data/models/journal_entry_model.dart';
import 'package:antibet/features/auth/presentation/providers/auth_provider.dart';

// Chave global para o Navigator, útil para o SnackBarUtils fora do contexto do widget.
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Provider para o GoRouter que permite acesso ao Ref.
final goRouterProvider = Provider<GoRouter>((ref) {
  // Observar o AuthProvider para reagir a mudanças de autenticação (ex: token expira -> redirect para /login)
  ref.watch(authProvider); 

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    
    // === LÓGICA DE REDIRECIONAMENTO (SEGURANÇA) ===
    redirect: (context, state) {
      final isAuthenticated = ref.read(authProvider).isAuthenticated;
      
      // Rotas que não requerem autenticação
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';
      
      // Define a rota de destino desejada (que não é login/registro)
      final isProtected = !isLoggingIn && !isRegistering;

      // Se não está autenticado E está tentando acessar uma rota protegida, redireciona para login
      if (!isAuthenticated && isProtected) {
        return '/login';
      }

      // Se está autenticado E está tentando acessar a tela de login/registro, redireciona para o diário
      if (isAuthenticated && (isLoggingIn || isRegistering)) {
        return '/journal';
      }

      // Nenhuma alteração necessária
      return null;
    },
    
    routes: [
      // === ROTAS DE AUTENTICAÇÃO ===
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // === ROTAS PRINCIPAIS (PROTEGIDAS) ===
      GoRoute(
        path: '/journal',
        builder: (context, state) => const JournalScreen(),
        routes: [
          // Sub-rotas do diário (CRUD)
          GoRoute(path: 'add', builder: (context, state) => const AddEntryScreen()),
          GoRoute(
            path: 'edit',
            builder: (context, state) {
              final JournalEntryModel? entry = state.extra as JournalEntryModel?;
              if (entry == null) return const JournalScreen(); 
              return EditEntryScreen(entry: entry);
            },
          ),
        ],
      ),
      
      // Rota de Configurações (protegida via redirect)
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      
      // Rota de fallback para 404
      GoRoute(
        path: '/:catchAll(.*)',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('404 - Página Não Encontrada'),
          ),
        ),
      ),
    ],
  );
});

// Getter simples para a instância do router (necessário para o main.dart e interceptors)
GoRouter get appRouter => goRouterProvider.notifier.router;