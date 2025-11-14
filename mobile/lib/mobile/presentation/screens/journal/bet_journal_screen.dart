import 'package:antibet/core/notifiers/bet_journal_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BetJournalScreen extends StatelessWidget {
  const BetJournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final journalNotifier = context.watch<BetJournalNotifier>();
    final entries = journalNotifier.entries;
    final isLoading = journalNotifier.isLoading;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history_toggle_off, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No bet history recorded yet.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Use the "+" button to start tracking your bets.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        
        // Calcula o lucro/prejuízo
        final netResult = entry.payout - entry.stake;
        final isWin = netResult > 0;
        final resultColor = isWin ? Colors.green.shade700 : (netResult < 0 ? Colors.red.shade700 : Colors.blue.shade700);
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: Icon(
              isWin ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: resultColor,
            ),
            title: Text(
              entry.description,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Stake: R\$${entry.stake.toStringAsFixed(2)} | Strategy: ${entry.strategyId}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isWin ? '+ R\$${netResult.toStringAsFixed(2)}' : 'R\$${netResult.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: resultColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  entry.result,
                  style: TextStyle(fontSize: 12, color: resultColor),
                ),
              ],
            ),
            onTap: () {
              // Navega para a tela de edição/detalhes da aposta
              // context.go('/bet_details/${entry.id}');
            },
          ),
        );
      },
    );
  }
}