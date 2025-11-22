// NOVO: Importa o modelo de entrada
import 'package:antibet/features/journal/models/journal_model.dart';
import 'package:antibet/features/journal/presentation/widgets/journal_entry_item.dart'; // NOVO: Importa o widget de item
import 'package:antibet/features/journal/presentation/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// [JournalStats] é um widget focado em exibir as estatísticas
/// resumidas de um [JournalModel] específico.
class JournalStats extends StatelessWidget {
  const JournalStats({
    super.key,
    required this.journal,
  });

  final JournalModel journal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profitColor =
        journal.profit >= 0 ? theme.colorScheme.primary : theme.colorScheme.error;

    // Formatador para valores monetários
    final currencyFormatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Estatísticas Principais (Grid)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12.0,
            crossAxisSpacing: 12.0,
            childAspectRatio: 1.8, // Ajusta a altura dos cards
            children: [
              StatCard(
                title: 'Total de Apostas',
                value: journal.totalBets.toString(),
                icon: Icons.stacked_line_chart,
                iconColor: Colors.blueAccent,
              ),
              StatCard(
                title: 'Total de Vitórias',
                value: journal.totalWins.toString(),
                icon: Icons.check_circle_outline,
                iconColor: Colors.greenAccent,
              ),
              StatCard(
                title: 'Total de Perdas',
                value: journal.totalLost.toString(),
                icon: Icons.remove_circle_outline,
                iconColor: Colors.redAccent,
              ),
              StatCard(
                title: 'Lucro/Prejuízo',
                value: currencyFormatter.format(journal.profit),
                icon: journal.profit >= 0
                    ? Icons.trending_up
                    : Icons.trending_down,
                valueColor: profitColor,
                iconColor: profitColor,
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 24),

          // 2. Lista de Entradas (Journal Entries)
          Text(
            'Entradas do Dia',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildEntriesList(context),
        ],
      ),
    );
  }

  /// Constrói a lista de entradas.
  Widget _buildEntriesList(BuildContext context) {
    if (journal.entries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32.0),
          child: Text(
            'Nenhuma aposta registrada para este dia.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: journal.entries.length,
      itemBuilder: (context, index) {
        final entry = journal.entries[index];
        
        // Agora usa o novo widget JournalEntryItem
        return JournalEntryItem(
          entry: entry,
          onTap: () {
            // TODO: Implementar navegação para Edição de Aposta
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Detalhes da Aposta: ${entry.id}')),
            );
          },
        );
      },
    );
  }
}