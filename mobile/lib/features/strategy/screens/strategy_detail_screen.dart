import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import 'package:antibet/features/strategy/models/strategy_model.dart';
import 'package:antibet/features/strategy/providers/strategy_provider.dart';
import 'package:antibet/features/shared/widgets/app_layout.dart'; // Importação do AppLayout
import 'package:antibet/features/shared/widgets/action_separator.dart'; // Importação do ActionSeparator


// O decorator @RoutePage é exigido pelo auto_route
@RoutePage()
class StrategyDetailScreen extends StatelessWidget {
  final String strategyId;

  const StrategyDetailScreen({super.key, required this.strategyId});

  @override
  Widget build(BuildContext context) {
    final StrategyProvider strategyProvider = GetIt.I<StrategyProvider>();

    // Procura a estratégia na lista carregada no Provider
    // Usamos ListenableBuilder para reagir à mudança de estado (ex: após deleção ou atualização)
    return ListenableBuilder(
      listenable: strategyProvider,
      builder: (context, child) {
        final strategy = strategyProvider.strategies.firstWhere(
          (s) => s.id == strategyId,
          orElse: () => throw Exception('Estratégia não encontrada.'),
        ); 
        
        final dateFormat = DateFormat('dd/MM/yyyy');
        final isActive = strategy.isActive;

        return AppLayout( // Substitui o Scaffold principal
          appBar: AppBar(
            title: Text(strategy.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // context.router.push(EditStrategyRoute(strategy: strategy)); // Rota futura
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(context, strategyId, strategyProvider),
              ),
            ],
          ),
          child: SingleChildScrollView(
            // Padding removido, agora está no AppLayout
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // --- Status Principal ---
                Center(
                  child: Icon(
                    isActive ? Icons.check_circle : Icons.pause_circle_filled,
                    size: 80,
                    color: isActive ? Colors.green : Colors.amber,
                  ),
                ),
                Center(
                  child: Text(
                    isActive ? 'ATIVA' : 'PAUSADA',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                
                const ActionSeparator(), // Separador padronizado

                // --- Detalhes da Estratégia ---
                _buildDetailRow(context, 'ID da Estratégia:', strategy.id.substring(0, 8)),
                _buildDetailRow(context, 'Tipo de Trading:', strategy.type),
                _buildDetailRow(context, 'Data de Criação:', dateFormat.format(strategy.createdAt)),

                const ActionSeparator(), // Separador padronizado

                // --- Descrição e Regras ---
                Text('Descrição e Regras:', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    strategy.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),

                const SizedBox(height: 40),
                // --- Placeholder de Performance (Futuro) ---
                Text('Performance (Dados Futuros):', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const Text('Aqui será exibido o ROI, Drawdown e outros KPIs gerados por esta estratégia.'),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Widget utilitário para formatar uma linha de detalhe.
  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  /// Exibe um diálogo de confirmação antes de excluir.
  void _confirmDelete(BuildContext context, String strategyId, StrategyProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza de que deseja excluir permanentemente esta estratégia?'),
        actions: [
          TextButton(
            onPressed: () => context.router.pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              context.router.pop(); // Fecha o diálogo
              await provider.deleteStrategy(strategyId); // Chama a exclusão
              context.router.pop(); // Retorna para a lista
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}