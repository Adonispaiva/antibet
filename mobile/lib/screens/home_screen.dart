import 'package:flutter/material.dart';
import 'package:inovexa_antibet/providers/auth_provider.dart';
import 'package:inovexa_antibet/screens/ai_chat_screen.dart';
import 'package:inovexa_antibet/screens/goals/goals_screen.dart'; // (Novo)
import 'package:inovexa_antibet/screens/journal/journal_screen.dart';
import 'package:inovexa_antibet/screens/plans_screen.dart'; 
import 'package:inovexa_antibet/utils/app_colors.dart';
import 'package:inovexa_antibet/utils/app_typography.dart';
import 'package:inovexa_antibet/widgets/app_layout.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final planName = user?.plan.name ?? 'Carregando...';

    return AppLayout(
      title: 'AntiBet Dashboard',
      showAppBar: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Sair',
          onPressed: () {
            authProvider.logout();
          },
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- Card de Status (v1.3) ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seu Plano Atual:',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textDark.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        planName,
                        style: AppTypography.title.copyWith(fontSize: 20),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const PlansScreen()),
                      );
                    },
                    child: const Text('Upgrade'),
                  ),
                ],
              ),
            ),
            
            const Spacer(flex: 1), 

            // --- CTAs (Ações Principais) ---
            const Text(
              'O que faremos hoje?',
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Botão 1: Chat
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AiChatScreen()),
                );
              },
              child: const Text('Iniciar Conversa com Assistente'),
            ),
            const SizedBox(height: 16), // (Espaçamento ajustado)

            // Botão 2: Diário
            _buildSecondaryButton(
              context,
              text: 'Acessar Meu Diário',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const JournalScreen()),
                );
              },
            ),
            const SizedBox(height: 16), // (Espaçamento ajustado)

            // (Novo) Botão 3: Metas
            _buildSecondaryButton(
              context,
              text: 'Definir Minhas Metas',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const GoalsScreen()),
                );
              },
            ),
            
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  // Helper para botões secundários (Diário e Metas)
  Widget _buildSecondaryButton(BuildContext context, {required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.primary,
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}