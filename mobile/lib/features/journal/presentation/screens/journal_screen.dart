import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:antibet/features/journal/data/models/journal_entry_model.dart';
import 'package:antibet/features/journal/presentation/providers/journal_provider.dart';
import 'package:antibet/features/journal/presentation/widgets/journal_entry_item.dart';
import 'package:antibet/features/journal/presentation/widgets/journal_stats.dart';
import 'package:antibet/features/auth/presentation/providers/auth_provider.dart';
import 'package:antibet/features/auth/data/services/auth_service.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  // Função para lidar com o logout
  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    // 1. Chamar o logout no backend
    try {
      await ref.read(authServiceProvider).logout();
    } catch (e) {
      // Ignoramos erros do backend no logout
    }

    // 2. Limpar o estado de autenticação (limpa o token e remove do storage)
    await ref.read(authProvider.notifier).logout();
    
    // 3. Navegar para a tela de login
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalState = ref.watch(journalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seu Diário AntiBet'),
        actions: [
          // Botão para navegar para as Configurações (NOVO)
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.go('/settings');
            },
            tooltip: 'Configurações',
          ),
          // Botão para atualizar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(journalProvider.notifier).getJournal();
            },
            tooltip: 'Atualizar Diário',
          ),
          // Botão para Logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context, ref),
            tooltip: 'Sair da Conta',
          ),
        ],
      ),
      body: journalState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Erro ao carregar o diário: ${err.toString().replaceAll('Exception: ', '')}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
        data: (journalModel) {
          final entries = journalModel.entries;
          
          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Nenhuma aposta registrada ainda.'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      ref.read(journalProvider.notifier).getJournal();
                    },
                    child: const Text('Tentar recarregar?'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: entries.length + 1, // +1 para as estatísticas
            itemBuilder: (context, index) {
              if (index == 0) {
                // Primeira seção: Estatísticas
                return JournalStats(journal: journalModel);
              }
              
              // Seções seguintes: Itens do diário
              final JournalEntryModel entry = entries[index - 1];
              return InkWell(
                onTap: () {
                  // Navegação para a tela de edição, passando o objeto JournalEntryModel
                  context.go('/journal/edit', extra: entry); 
                },
                child: JournalEntryItem(entry: entry),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/journal/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}