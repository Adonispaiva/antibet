import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antibet/features/journal/providers/journal_provider.dart';

class JournalStats extends ConsumerWidget {
  const JournalStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Observa o estado dos dados do JournalProvider
    final journalState = ref.watch(journalProvider);

    // 2. Calcula as estatísticas
    return journalState.when(
      loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Calculando estatísticas...', style: TextStyle(color: Colors.grey)),
          )),
      error: (error, stack) => const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Estatísticas indisponíveis.', style: TextStyle(color: Colors.red)),
      ),
      data: (entries) {
        if (entries.isEmpty) {
          return const SizedBox.shrink(); // Não mostra stats se não houver entradas
        }

        // Soma do lucro/prejuízo (valores negativos são prejuízo)
        final totalNetProfit = entries.fold(0.0, (sum, entry) => sum + entry.amount);
        
        // Volume total de apostas (soma de todos os valores absolutos apostados)
        final totalVolume = entries.fold(0.0, (sum, entry) => sum + entry.amount.abs());
        
        // Número total de apostas
        final betCount = entries.length;

        // Determina a cor com base no lucro/prejuízo
        final profitColor = totalNetProfit >= 0 ? Colors.green.shade700 : Colors.red.shade700;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Estatística principal: Lucro/Prejuízo Líquido
              Card(
                elevation: 2,
                color: profitColor.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        totalNetProfit >= 0 ? 'Lucro Líquido' : 'Prejuízo Líquido',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: profitColor,
                        ),
                      ),
                      Text(
                        'R\$ ${totalNetProfit.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: profitColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Estatísticas secundárias: Volume e Contagem
              Row(
                children: [
                  // Contagem de Apostas
                  Expanded(
                    child: StatTile(
                      label: 'Total de Apostas',
                      value: betCount.toString(),
                      icon: Icons.list_alt,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Volume Total
                  Expanded(
                    child: StatTile(
                      label: 'Volume Total',
                      value: 'R\$ ${totalVolume.toStringAsFixed(2)}',
                      icon: Icons.paid,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// Widget auxiliar para exibir cada estatística
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}