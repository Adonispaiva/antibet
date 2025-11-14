import 'packageD:flutter/material.dart';
import 'packageD:provider/provider.dart';
import 'packageD:antibet/core/notifiers/bet_journal_notifier.dart';
import 'packageD:antibet/core/models/bet_journal_entry_model.dart'; // Pressupondo que o caminho é este

/// Tela responsável por exibir e gerenciar a lista de lançamentos (apostas)
/// do usuário (Tab 1 da Dashboard).
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {

  /// Simula a adição de um novo lançamento.
  void _addNewEntry(BuildContext context) {
    // Obtém o notifier (listen: false) pois é uma ação
    final journalNotifier = Provider.of<BetJournalNotifier>(context, listen: false);

    // Cria um lançamento de simulação
    final newEntry = BetJournalEntryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      stake: 50.0,
      odds: 1.85,
      result: BetResult.pending, // Pendente
      strategyId: '1',
      description: 'Simulação de Lançamento',
    );
    
    // Adiciona o lançamento através do notifier
    journalNotifier.addEntry(newEntry);
  }

  @override
  Widget build(BuildContext context) {
    // Consome o notifier (listen: true) para reagir a mudanças na lista
    final journalNotifier = Provider.of<BetJournalNotifier>(context);
    final entries = journalNotifier.entries;

    return Scaffold(
      body: entries.isEmpty
          ? _buildEmptyState()
          : _buildEntriesList(entries),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewEntry(context),
        tooltip: 'Adicionar Lançamento',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Constrói o estado de lista vazia.
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Nenhum lançamento encontrado.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          Text(
            'Use o botão (+) para adicionar.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Constrói a lista de lançamentos (ListView).
  Widget _buildEntriesList(List<BetJournalEntryModel> entries) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: Icon(
              entry.result == BetResult.won ? Icons.check_circle_outline :
              entry.result == BetResult.lost ? Icons.highlight_off :
              Icons.hourglass_empty,
              color: entry.result == BetResult.won ? Colors.green :
                     entry.result == BetResult.lost ? Colors.red :
                     Colors.grey,
            ),
            title: Text('Aposta R\$ ${entry.stake.toStringAsFixed(2)} @ ${entry.odds}'),
            subtitle: Text(entry.description.isEmpty ? 'Data: ${entry.date.toLocal()}' : entry.description),
            trailing: Text(entry.result.toString().split('.').last.toUpperCase()),
          ),
        );
      },
    );
  }
}