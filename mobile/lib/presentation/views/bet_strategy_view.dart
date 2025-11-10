import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Importações dos notifiers e modelos
import '../../notifiers/bet_strategy_notifier.dart';
import '../../core/domain/bet_strategy_model.dart';
import '../../core/navigation/app_router.dart'; 

class BetStrategyView extends StatefulWidget {
  const BetStrategyView({super.key});

  @override
  State<BetStrategyView> createState() => _BetStrategyViewState();
}

class _BetStrategyViewState extends State<BetStrategyView> {

  @override
  void initState() {
    super.initState();
    // Inicia a busca pelas estratégias assim que a View for construída
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BetStrategyNotifier>().fetchStrategies();
    });
  }

  /// Navega para o formulário de CRUD, passando a estratégia para edição ou null para criação
  void _navigateToForm({BetStrategyModel? strategy}) {
    context.goNamed(
      AppRoute.strategy_form.name,
      extra: strategy, // Objeto BetStrategyModel será passado via 'extra'
    );
  }

  /// Manipula a exclusão da estratégia
  Future<void> _handleDelete(BuildContext context, BetStrategyModel strategy, BetStrategyNotifier notifier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir a regra de controle "${strategy.name}"?'), // Ajuste de Tom
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Excluir', style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirmed) {
      try {
        await notifier.deleteStrategy(strategy.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Regra de controle "${strategy.name}" excluída com sucesso!')), // Ajuste de Tom
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao excluir regra: ${notifier.errorMessage}')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Regras de Controle'), // Ajuste de Tom
      ),
      // Botão para adicionar nova estratégia (Criação)
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(), // Navega para Criação (strategy = null)
        child: const Icon(Icons.add),
      ),
      body: Consumer<BetStrategyNotifier>(
        builder: (context, notifier, child) {
          switch (notifier.state) {
            case StrategyState.loading:
            case StrategyState.initial:
              return const Center(child: CircularProgressIndicator());
            
            case StrategyState.error:
              return _buildErrorWidget(context, notifier);

            case StrategyState.loaded:
              return _buildLoadedList(context, notifier.strategies, notifier);
          }
        },
      ),
    );
  }
  
  // Widget de exibição de erro
  Widget _buildErrorWidget(BuildContext context, BetStrategyNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning, color: Colors.orange, size: 50),
            const SizedBox(height: 10),
            Text(
              'Erro ao carregar regras: ${notifier.errorMessage}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: notifier.fetchStrategies, // Tenta recarregar
              child: const Text('Recarregar'),
            ),
          ],
        ),
      ),
    );
  }
  
  // Widget de exibição da lista
  Widget _buildLoadedList(BuildContext context, List<BetStrategyModel> strategies, BetStrategyNotifier notifier) {
    if (strategies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Nenhuma regra de controle cadastrada. Defina sua primeira regra!'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: notifier.fetchStrategies,
              child: const Text('Buscar Novamente'),
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
            leading: Icon(
              strategy.isActive ? Icons.check_circle : Icons.cancel,
              color: strategy.isActive ? Colors.green : Colors.grey,
            ),
            title: Text(strategy.name),
            subtitle: Text(
              'Risco Máximo: ${(strategy.riskFactor * 100).toInt()}% - ${strategy.description}', // Ajuste de Texto
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: SizedBox(
              width: 100,
              child: Row(
                children: [
                   // Botão de Edição
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _navigateToForm(strategy: strategy), // Navega para Edição
                  ),
                  // Botão de Exclusão
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _handleDelete(context, strategy, notifier), 
                  ),
                ],
              ),
            ),
            onTap: () {
              // TODO: Navegar para detalhes ou alternar estado ativo
            },
          ),
        );
      },
    );
  }
}