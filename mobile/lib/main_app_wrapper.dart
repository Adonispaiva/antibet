import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antibet/features/auth/providers/auth_provider.dart';
import 'package:antibet/features/auth/screens/login_screen.dart';
import 'package:antibet/features/journal/screens/journal_screen.dart';

// Esta classe é o ponto de decisão de roteamento do aplicativo
class MainAppWrapper extends ConsumerWidget {
  const MainAppWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observa o estado de autenticação para determinar qual tela mostrar
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'AntiBet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // Usa o construtor when do AsyncValue para lidar com os três estados
      home: authState.when(
        // 1. Estado de Carregamento (Inicialização/Auto-login)
        loading: () => const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Carregando sessão...'),
              ],
            ),
          ),
        ),
        
        // 2. Estado de Erro (Falha ao iniciar a sessão)
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('Erro Crítico')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'Erro ao iniciar o aplicativo: ${error.toString()}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ),

        // 3. Estado de Dados (Decisão de Roteamento)
        data: (user) {
          if (user != null) {
            // Se o UserModel existe, o usuário está logado -> Vai para o Journal
            return const JournalScreen();
          } else {
            // Se o UserModel é null, o usuário não está logado -> Vai para o Login
            return const LoginScreen();
          }
        },
      ),
    );
  }
}