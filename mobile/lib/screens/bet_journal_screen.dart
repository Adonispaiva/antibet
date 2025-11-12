import 'package:antibet_mobile/core/navigation/app_router.dart';
import 'package:antibet_mobile/models/bet_journal_entry_model.dart';
import 'package:antibet_mobile/notifiers/bet_journal_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Tela de Histórico e Diário de Apostas.
///
/// Exibe as estatísticas consolidadas e a lista de entradas registradas
/// no [BetJournalNotifier].
class BetJournalScreen extends StatefulWidget {
  const BetJournalScreen({super.key});

  @override
  State<BetJournalScreen> createState() => _BetJournalScreenState();
}

class _BetJournalScreenState extends State<BetJournalScreen> {
  @override
  void initState() {
    super.initState();
    // Dispara a ação para carregar o histórico de apostas na inicialização.
    Provider.of<BetJournalNotifier>(context, listen: false).fetchEntries();
  }

  /// Navega para a tela de adicionar nova entrada.
  void _onAddPressed(BuildContext context) async {
    // Navega e espera o retorno. O retorno não é obrigatório,
    // mas o `fetchEntries` será chamado no `didPop` para atualizar a lista.
    await Navigator.of(context).pushNamed(AppRouter.addBetJournalEntryRoute);
    
    // Força a atualização da lista ao retornar, caso uma nova aposta tenha sido adicionada.
    // O fetchEntries tem lógica de loading, então não causa problemas se chamado rapidamente.
    if(mounted) {
      context.read<BetJournalNotifier>().fetchEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observa o Notifier para atualizações de estado
    final notifier = context.watch<BetJournalNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário de Apostas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: notifier.isLoading
                ? null
                : () => notifier.fetchEntries(),
          ),
        ],
      ),
      body: _buildBody(context, notifier),
      
      // --- Floating Action Button ADICIONADO ---
      floatingActionButton: FloatingActionButton(
        onPressed: notifier.isLoading ? null : () => _onAddPressed(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context, BetJournalNotifier notifier) {
    // 1. Estado de Carregamento
    if (notifier.isLoading && notifier.entries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Estado de Erro
    if (notifier.hasError && notifier.entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              notifier.errorMessage ?? 'Erro ao carregar histórico.',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => notifier.fetchEntries(),
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    // 3. Estado de Sucesso (com dados ou lista vazia)
    if (notifier.entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Nenhuma aposta registrada ainda.'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: notifier.isLoading ? null : () => _onAddPressed(context),
              icon: const Icon(Icons.add),
              label: const Text('Registrar Primeira Aposta'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // --- Estatísticas Consolidadas ---
        _buildStatsSummary(context, notifier),
        
        // --- Lista de Entradas ---
        Expanded(
          child: ListView.builder(
            itemCount: notifier.entries.length,
            itemBuilder: (context, index) {
              final entry = notifier.entries[index];
              return _buildJournalTile(context, entry);
            },
          ),
        ),
      ],
    );
  }

  /// Constrói a linha de resumo de estatísticas.
  Widget _buildStatsSummary(BuildContext context, BetJournalNotifier notifier) {
    // Cor do Lucro Total
    Color profitColor = notifier.totalProfit >= 0 ? Colors.green.shade400 : Colors.red.shade400;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: const [BoxShadow(blurRadius: 2, color: Colors.black26)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem('Lucro Total', 'R\$ ${notifier.totalProfit.toStringAsFixed(2)}', profitColor),
          _buildStatItem('Vitórias', notifier.winCount.toString(), Colors.green.shade400),
          _buildStatItem('Derrotas', notifier.lossCount.toString(), Colors.red.shade400),
          _buildStatItem('Pendentes', notifier.pendingCount.toString(), Colors.grey.shade400),
        ],
      ),
    );
  }
  
  /// Helper para construir um item de estatística.
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  /// Constrói o tile para uma entrada individual do diário.
  Widget _buildJournalTile(BuildContext context, BetJournalEntryModel entry) {
    final statusData = _getStatusData(entry.status);

    return ListTile(
      leading: Icon(statusData['icon'] as IconData, color: statusData['color'] as Color),
      title: Text('Aposta de R\$ ${entry.stake.toStringAsFixed(2)}'),
      subtitle: Text(entry.notes.isEmpty ? 'Sem notas' : entry.notes, maxLines: 1),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            statusData['text'] as String,
            style: TextStyle(color: statusData['color'] as Color, fontWeight: FontWeight.bold),
          ),
          Text(
            'Lucro: R\$ ${entry.profit.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 12, color: entry.profit >= 0 ? Colors.green : Colors.red),
          ),
        ],
      ),
      onTap: () {
        // TODO: Navegar para tela de detalhes ou edição da entrada
      },
    );
  }

  /// Helper para retornar dados de UI (Texto, Cor, Ícone) com base no Status.
  Map<String, dynamic> _getStatusData(BetStatus status) {
    switch (status) {
      case BetStatus.win:
        return {'text': 'VITÓRIA', 'icon': Icons.check_circle, 'color': Colors.green.shade400};
      case BetStatus.loss:
        return {'text': 'PERDA', 'icon': Icons.cancel, 'color': Colors.red.shade400};
      case BetStatus.pending:
        return {'text': 'PENDENTE', 'icon': Icons.schedule, 'color': Colors.amber.shade400};
      case BetStatus.voided:
        return {'text': 'NULA', 'icon': Icons.not_interested, 'color': Colors.grey.shade400};
      default:
        return {'text': 'N/D', 'icon': Icons.help_outline, 'color': Colors.grey.shade400};
    }
  }
}