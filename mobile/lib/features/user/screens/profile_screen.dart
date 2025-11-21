import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';

import 'package:antibet/features/user/providers/user_provider.dart';
import 'package:antibet/features/shared/widgets/app_layout.dart';
import 'package:antibet/features/shared/widgets/action_separator.dart';
import 'package:antibet/features/shared/widgets/app_bar_action_button.dart';
import 'package:antibet/core/routing/app_router.dart'; // Necessário para navegar para rotas fora da MainShell


// O decorator @RoutePage é exigido pelo auto_route
@RoutePage()
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Acessa o UserProvider
    final UserProvider userProvider = GetIt.I<UserProvider>();
    
    return ListenableBuilder(
      listenable: userProvider,
      builder: (context, child) {
        final user = userProvider.currentUser;

        if (user == null) {
            // Em caso de falha, redireciona o usuário (após o AppRouter ser reconfigurado)
            // context.router.replaceAll([const LoginScreenRoute()]);
            return const Center(child: Text('Sessão inválida.'));
        }

        return AppLayout( // Substitui o Scaffold principal
          appBar: AppBar(
            title: const Text('Meu Perfil'),
            actions: [
              // Botão para Notificações (Acesso rápido)
              AppBarActionButton(
                icon: Icons.notifications_none,
                onTap: () {
                  // Navega para a rota de notificações
                  context.router.push(const NotificationRoute());
                },
              ),
              // Botão para o Chat AI (Acesso rápido)
              AppBarActionButton(
                icon: Icons.psychology_outlined,
                onTap: () {
                  // Navega para a rota do chat AI
                  context.router.push(const AiChatRoute());
                },
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24), // Espaçamento superior
                
                // --- Avatar e Informações Básicas ---
                const Center(
                  child: CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person, size: 40),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    user.name, 
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Center(
                  child: Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                
                const ActionSeparator(), // Separador padronizado

                // --- Opções de Gerenciamento ---
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Editar Informações do Perfil'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // context.router.push(EditProfileRoute()); // Rota futura
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Alterar Senha'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // context.router.push(ChangePasswordRoute()); // Rota futura
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.star),
                  title: const Text('Gerenciar Planos (Assinatura)'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // context.router.push(BillingRoute()); // Rota futura
                  },
                ),
                
                const ActionSeparator(), // Separador padronizado
                
                // --- Botão de Logout ---
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: TextButton.icon(
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text('Sair da Conta', style: TextStyle(color: Colors.red)),
                      onPressed: () async {
                        // Chama o Provider para limpar o estado e o token
                        await userProvider.logout();
                        // O listener na MainShellScreen cuidará do redirecionamento
                        context.router.replaceAll([const LoginScreenRoute()]);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}