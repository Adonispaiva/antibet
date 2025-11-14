// mobile/lib/features/journal/screens/journal_screen.dart

import 'package:antibet/features/journal/models/journal_entry_model.dart';
import 'package:antibet/features/journal/notifiers/journal_notifier.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatação de data
import 'package:provider/provider.dart'; 

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});
  
  // Placeholder para a tela de criação
  void _navigateToCreateEntry(BuildContext context) {
      // TODO: Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateJournalEntryScreen()));
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navegação para Criar Entrada (Ainda não implementado)')),
      );
  }

  @override
  Widget build(BuildContext context) {
    // Escuta as mudanças no JournalNotifier
    final journalNotifier = context.watch<JournalNotifier>();
    final entries = journalNotifier.entries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário de Análises'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implementar lógica de filtro (usando o DTO de filtro do Backend)
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => journalNotifier.fetchEntries(), // Recarrega
          ),
        ],
      ),
      body: journalNotifier.isLoading
          ? const Center(child: CircularProgressIndicator())
          : journalNotifier.errorMessage != null
              ? Center(child: Text('Erro: ${journalNotifier.errorMessage}'))
              : entries.isEmpty
                  ? const Center(
                      child: Text('Nenhuma entrada encontrada. Clique no "+" para começar.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return JournalEntryCard(entry: entry);
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateEntry(context),
        child: const Icon(Icons.add),
        tooltip: 'Nova Entrada no Diário',
      ),
    );
  }
}

/// Widget reutilizável para exibir uma entrada do diário.
class JournalEntryCard extends StatelessWidget {
  final JournalEntryModel entry;

  const JournalEntryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final bool isWin = entry.finalResult > 0;
    final bool isLoss = entry.finalResult < 0;
    final Color color = isWin ? Colors.green : (isLoss ? Colors.red : Colors.grey);
    final IconData icon = isWin ? Icons.trending_up : (isLoss ? Icons.trending_down : Icons.remove);
    final String resultText = 'R\$ ${entry.finalResult.toStringAsFixed(2)}';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          entry.strategyName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Análise: ${entry.preAnalysis.length > 50 ? entry.preAnalysis.substring(0, 50) + "..." : entry.preAnalysis}',
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(entry.entryDate)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Text(
          resultText,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () {
          // TODO: Navegar para a Tela de Detalhes/Edição da Entrada
        },
      ),
    );
  }
}