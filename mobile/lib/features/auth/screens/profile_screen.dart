import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antibet/features/auth/providers/auth_provider.dart';
import 'package:antibet/core/ui/feedback_manager.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Saída'),
          content: const Text('Tem certeza que deseja sair da sua conta AntiBet?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Sair', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        // Dispara o logout, que limpa o token e redireciona (via MainAppWrapper)
        await ref.read(authProvider.notifier).logout();
        FeedbackManager.showInfo(context, 'Sessão encerrada com sucesso.');
      } catch (e) {
        FeedbackManager.showError(context, 'Falha ao encerrar a sessão.');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Acesso otimista aos dados do usuário, já que esta tela só é acessível se o usuário estiver logado
    final user = ref.watch(authProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 20),
              
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('E-mail'),
                  subtitle: Text(user?.email ?? 'N/A'),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.person_pin),
                  title: const Text('Nome'),
                  subtitle: Text(user?.name ?? 'Usuário AntiBet'),
                ),
              ),

              const SizedBox(height: 40),

              // Botão de Logout
              ElevatedButton.icon(
                onPressed: () => _confirmLogout(context, ref),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Sair da Conta', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),

              const SizedBox(height: 20),
              const Text('Versão 1.0.0 (MVP) - Inovexa Software', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}