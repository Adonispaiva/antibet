import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Importações dos Notifiers e Telas necessárias
import 'package:mobile/notifiers/auth_notifier.dart';
import 'package:mobile/notifiers/lockdown_notifier.dart';
import 'package:mobile/screens/login/login_screen.dart';
import 'package:mobile/screens/registration/register_screen.dart'; // Usando a pasta 'registration'
import 'package:mobile/screens/home/home_screen.dart';
// Importação placeholder para a tela de Lockdown
// import 'package:mobile/screens/lockdown/lockdown_screen.dart'; 

// O AppRouter é responsável por definir e gerenciar o fluxo de navegação
// reativo da aplicação (padrão de Arquitetura Limpa/Provider-based).
class AppRouter {
  final AuthNotifier _authNotifier;
  final LockdownNotifier _lockdownNotifier;
  
  // Rota estática para a tela de Lockdown (se necessário)
  static const String lockdownRoute = '/lockdown';

  AppRouter(this._authNotifier, this._lockdownNotifier);

  // O GoRouter é instanciado aqui
  late final GoRouter router = GoRouter(
    // A chave Listenable é usada para que o router se reconstrua
    // sempre que o estado de autenticação ou bloqueio mude.
    refreshListenable: Listenable.merge([_authNotifier, _lockdownNotifier]),
    
    // Rota inicial ou de fallback
    initialLocation: LoginScreen.routeName, 
    
    // Lista das rotas da aplicação
    routes: [
      // 1. Rotas de Autenticação
      GoRoute(
        path: LoginScreen.routeName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RegisterScreen.routeName,
        builder: (context, state) => const RegisterScreen(),
      ),

      // 2. Rotas Principais (App Flow)
      GoRoute(
        path: HomeScreen.routeName,
        builder: (context, state) => const HomeScreen(),
      ),

      // 3. Rota de Lockdown (Simulada)
      GoRoute(
        path: lockdownRoute,
        // builder: (context, state) => const LockdownScreen(),
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('🔒 BLOQUEADO: Manutenção Crítica de Sistema', 
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, color: Colors.red))),
        ),
      ),
    ],

    // === LÓGICA DE REDIRECIONAMENTO REATIVO ===
    // Chamado sempre que a localização muda ou quando o refreshListenable notifica.
    redirect: (context, state) {
      // 1. CHECAGEM DE LOCKDOWN (Prioridade Máxima)
      // Se o sistema estiver em Lockdown, redireciona para a tela de Lockdown, independentemente do estado de autenticação.
      if (_lockdownNotifier.isSystemLocked) {
        // Permite o acesso à rota de Lockdown (para evitar loops infinitos)
        return (state.fullPath == lockdownRoute) ? null : lockdownRoute;
      }
      
      // Se o Lockdown não estiver ativo, remove qualquer tentativa de ir para a rota de Lockdown
      if (state.fullPath == lockdownRoute) {
        // Redireciona para o login se não autenticado, ou para a home se autenticado
        return _authNotifier.isAuthenticated ? HomeScreen.routeName : LoginScreen.routeName;
      }

      // 2. CHECAGEM DE AUTENTICAÇÃO
      final bool isAuthenticated = _authNotifier.isAuthenticated;
      final bool isGoingToAuth = state.fullPath == LoginScreen.routeName || state.fullPath == RegisterScreen.routeName;

      // Se o usuário está autenticado E tentando acessar Login/Register, redireciona para a Home.
      if (isAuthenticated && isGoingToAuth) {
        return HomeScreen.routeName;
      }
      
      // Se o usuário NÃO está autenticado E tentando acessar a Home (ou qualquer rota protegida), redireciona para o Login.
      if (!isAuthenticated && !isGoingToAuth) {
        return LoginScreen.routeName;
      }

      // Se não houver necessidade de redirecionamento, permite a navegação.
      return null;
    },
  );
}