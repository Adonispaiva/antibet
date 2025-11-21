import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antibet/core/ui/feedback_manager.dart';
import 'package:antibet/features/journal/providers/journal_provider.dart';
import 'package:antibet/features/journal/screens/add_entry_screen.dart';
import 'package:antibet/features/journal/widgets/journal_entry_item.dart';
import 'package:antibet/features/journal/widgets/journal_stats.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalState = ref.watch(journalProvider);

    ref.listen<AsyncValue>(journalProvider, (_, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          // CORREÇÃO: .toString() para converter Object em String
          FeedbackManager.showError(context, 'Erro: ${error.toString()}');
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário de Apostas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(journalProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const JournalStats(), 
          const Divider(),
          Expanded(
            child: journalState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    // CORREÇÃO: .toString() obrigatório aqui também
                    'Falha ao carregar o diário.\nErro: ${error.toString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
              
              data: (entries) {
                if (entries.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhuma aposta registrada. Use o "+" para começar.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return JournalEntryItem(entry: entry);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEntryScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}