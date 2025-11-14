import 'package:antibet/core/notifiers/bet_strategy_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StrategyScreen extends StatelessWidget {
  const StrategyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strategyNotifier = context.watch<BetStrategyNotifier>();
    final strategies = strategyNotifier.strategies;
    final isLoading = strategyNotifier.isLoading;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (strategies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.track_changes, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No strategies found. Tap "+" to add one.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Organize your bets under specific strategies for better analysis.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: strategies.length,
      itemBuilder: (context, index) {
        final strategy = strategies[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: const Icon(Icons.military_tech, color: Colors.indigo),
            title: Text(
              strategy.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(strategy.description.isEmpty 
              ? 'No description provided.' 
              : strategy.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navega para a tela de detalhes da estratégia.
              // context.go('/home/details/${strategy.id}');
            },
          ),
        );
      },
    );
  }
}