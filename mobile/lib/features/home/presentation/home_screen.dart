import 'package:flutter/material.dart';
import '../../chat/presentation/chat_screen.dart';
import '../../auth/presentation/login_screen.dart';
import '../../block/presentation/block_active_screen.dart'; // Importação da Tela de Bloqueio

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard AntiBet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Logout simples: volta para Login e remove histórico
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === CABEÇALHO DE BOAS-VINDAS ===
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.shield, size: 48, color: theme.colorScheme.onPrimaryContainer),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Proteção Ativa',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Você está há 0 dias sem apostar.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // === AÇÕES RÁPIDAS ===
            Text(
              'Ações Rápidas',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _ActionCard(
                  icon: Icons.chat_bubble_outline,
                  label: 'Falar com IA',
                  color: Colors.blueAccent,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ChatScreen()),
                    );
                  },
                ),
                _ActionCard(
                  icon: Icons.block,
                  label: 'Modo Bloqueio',
                  color: Colors.redAccent,
                  onTap: () {
                    // Navega para a tela de Bloqueio Ativo (Teste Manual de 1 minuto)
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const BlockActiveScreen(durationMinutes: 1),
                      ),
                    );
                  },
                ),
                _ActionCard(
                  icon: Icons.bar_chart,
                  label: 'Meu Progresso',
                  color: Colors.orangeAccent,
                  onTap: () {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gráficos em breve...')),
                    );
                  },
                ),
                _ActionCard(
                  icon: Icons.settings,
                  label: 'Configurações',
                  color: Colors.grey,
                  onTap: () {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Configurações em breve...')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      // Botão de Pânico Flutuante
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // O botão de pânico leva direto ao Chat de Intervenção
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
        },
        backgroundColor: Colors.red,
        icon: const Icon(Icons.sos, color: Colors.white),
        label: const Text('AJUDA AGORA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}