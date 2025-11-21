import 'package:antibet/features/auth/presentation/login_screen.dart';
import 'package:antibet/features/auth/presentation/splash_screen.dart';
import 'package:antibet/features/auth/providers/user_provider.dart';
import 'package:antibet/features/journal/presentation/journal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// O [HomeScreen] atua como o principal widget de "roteamento" ou "wrapper"
/// da aplicação após o [main.dart].
///
/// Ele escuta o [userProvider] e decide qual tela principal
/// deve ser exibida com base no estado de autenticação (UserState).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuta o estado do userProvider
    final userState = ref.watch(userProvider);

    // Utiliza um 'switch' no 'state' para determinar a UI.
    // O 'whenOrNull' garante que, mesmo que um estado não seja
    // tratado, ele tenha um fallback (o 'orElse').
    return userState.whenOrNull(
      // Se o estado for UserLoaded, o usuário está autenticado.
      loaded: (user) => const JournalScreen(),

      // Se o estado for UserLoggedOut ou UserError,
      // o usuário precisa se autenticar.
      loggedOut: () => const LoginScreen(),
      error: (message) => const LoginScreen(),

      // O 'orElse' captura qualquer outro estado (como UserInitial
      // ou UserLoading) e exibe o SplashScreen.
      orElse: () => const SplashScreen(),
    )!;

    /*
    // Abordagem alternativa usando 'when' (mais verbosa, mas mais segura contra tipos)
    return userState.when(
      initial: () => const SplashScreen(),
      loading: () => const SplashScreen(),
      loaded: (user) => const JournalScreen(),
      loggedOut: () => const LoginScreen(),
      error: (message) => const LoginScreen(),
    );
    */
  }
}