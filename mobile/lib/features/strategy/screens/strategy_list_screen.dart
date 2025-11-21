import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:antibet/features/strategy/providers/strategy_provider.dart';
import 'package:antibet/features/shared/widgets/app_layout.dart'; // Importação do AppLayout
import 'package:antibet/features/shared/widgets/empty_state_widget.dart'; // Importação do EmptyStateWidget
import 'package:antibet/features/shared/widgets/status_badge.dart'; // Importação do StatusBadge
import 'package:antibet/core/routing/app_router.dart'; // Para navegação


// O decorator @RoutePage é exigido pelo auto_route
@RoutePage()
class StrategyListScreen extends StatefulWidget {
  const StrategyListScreen({super.key});

  @override
  State<StrategyListScreen> createState() => _StrategyListScreenState();
}

class _StrategyListScreenState extends State<StrategyListScreen> {
  final StrategyProvider _strategyProvider = GetIt.I<StrategyProvider>();

  @override
  void initState() {
    super.initState();
    // Dispara o carregamento inicial dos dados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _strategyProvider.fetchStrategies();
    });
  }
  
  /// Deleta uma estratégia e atualiza a UI.
  Future<void> _deleteStrategy(String strategyId) async {
    try {
      await _strategyProvider.deleteStrategy(strategyId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estratégia deletada com sucesso.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao deletar: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _strategyProvider,
      builder: (context, child) {
        
        final bool isLoading = _strategyProvider.isLoading && _strategyProvider.strategies.isEmpty;

        Widget content;

        // 2. Error State
        if (_strategyProvider.errorMessage != null) {
          content = EmptyStateWidget.error(
            title: 'Erro de Conexão',
            subtitle: _strategyProvider.errorMessage,
            action: ElevatedButton.icon(
              onPressed: _strategyProvider.fetchStrategies,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          );
        }
        
        // 3. Empty State
        else if (_strategyProvider.strategies.isEmpty && !_strategyProvider.isLoading) {
          content = EmptyStateWidget.noData(
            title: 'Nenhuma Estratégia',
            subtitle: 'Crie estratégias para organizar e categorizar seus trades.',
            action: ElevatedButton.icon(
              onPressed: () {
                context.router.push(const StrategyCreationRoute()); // Navega para criação
              },
              icon: const Icon(Icons.add),
              label: const Text('Criar Nova Estratégia'),
            ),
          );
        }

        // 4. Data Display
        else {
          content = ListView.builder(
            itemCount: _strategyProvider.strategies.length,
            itemBuilder: (context, index) {
              final strategy = _strategyProvider.strategies[index];
              final isActive = strategy.isActive;
              
              return ListTile(
                leading: isActive 
                    ? StatusBadge.success('Ativa') 
                    : StatusBadge.neutral('Pausada'),
                title: Text(strategy.name),
                subtitle: Text(strategy.type),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteStrategy(strategy.id),
                ),
                onTap: () {
                  context.router.push(StrategyDetailRoute(strategyId: strategy.id));
                },
              );
            },
          );
        }
        
        // Estrutura principal
        return Scaffold(
          appBar: AppBar(
            title: const Text('Minhas Estratégias'),
          ),
          body: AppLayout(
            isLoading: isLoading,
            appBar: null,
            useSafeArea: true,
            child: Padding(
              padding: EdgeInsets.zero, // Remove o padding horizontal do AppLayout para a lista
              child: content,
            ),
          ),
          // FAB para adicionar nova estratégia
          floatingActionButton: FloatingActionButton(
            onPressed: isLoading ? null : () {
              context.router.push(const StrategyCreationRoute());
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}