import 'package:antibet_mobile/core/navigation/app_router.dart';
import 'package:antibet_mobile/models/strategy_model.dart';
import 'package:antibet_mobile/notifiers/bet_strategy_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Tela de Listagem de Estratégias de Aposta.
///
/// Contém a lógica para carregar o [BetStrategyNotifier] e exibir a lista
/// de estratégias disponíveis, tratando os estados de loading e erro.
class StrategyListScreen extends StatefulWidget {
  const StrategyListScreen({super.key});

  @override
  State<StrategyListScreen> createState() => _StrategyListScreenState();
}

class _StrategyListScreenState extends State<StrategyListScreen> {
  @override
  void initState() {
    super.initState();
    // Dispara a ação para carregar as estratégias assim que a tela é construída.
    Provider.of<BetStrategyNotifier>(context, listen: false).loadStrategies();
  }

  /// Navega para a tela de detalhes.
  void _onStrategyTapped(BuildContext context, StrategyModel strategy) {
    Navigator.of(context).pushNamed(
      AppRouter.strategyDetailRoute,
      arguments: strategy, // Passa o objeto StrategyModel como argumento
    );
  }

  @override
  Widget build(BuildContext context) {
    // Não precisa de Scaffold nem AppBar, pois será usado dentro do shell (HomeScreen)
    return _buildStrategiesList();
  }

  /// Constrói o corpo da tela com base no estado do [BetStrategyNotifier].
  Widget _buildStrategiesList() {
    // Observa o Notifier de Estratégias
    final strategyNotifier = context.watch<BetStrategyNotifier>();

    // 1. Estado de Carregamento
    if (strategyNotifier.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 2. Estado de Erro
    if (strategyNotifier.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                strategyNotifier.errorMessage ?? 'Ocorreu um erro.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                // Tenta carregar novamente
                onPressed: () =>
                    context.read<BetStrategyNotifier>().loadStrategies(),
                child: const Text('Tentar Novamente'),
              )
            ],
          ),
        ),
      );
    }

    // 3. Estado de Sucesso (com dados)
    final List<StrategyModel> strategies = strategyNotifier.strategies;
    
    // (Trata o caso de lista vazia)
    if (strategies.isEmpty) {
        return Center(
          child: Text(
            strategyNotifier.errorMessage ?? 'Nenhuma estratégia disponível no momento.',
            textAlign: TextAlign.center,
          ),
        );
    }

    // 4. Exibe a lista
    return ListView.builder(
      itemCount: strategies.length,
      itemBuilder: (context, index) {
        final strategy = strategies[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Icon(_getRiskIcon(strategy.riskLevel), size: 40),
            title: Text(strategy.title),
            subtitle: Text(strategy.description, maxLines: 2, overflow: TextOverflow.ellipsis,),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _onStrategyTapped(context, strategy);
            },
          ),
        );
      },
    );
  }

  /// Helper para retornar um ícone com base no Risco.
  IconData _getRiskIcon(StrategyRiskLevel risk) {
    switch (risk) {
      case StrategyRiskLevel.low:
        return Icons.check_circle_outline; // Ícone de baixo risco
      case StrategyRiskLevel.medium:
        return Icons.warning_amber_rounded; // Ícone de médio risco
      case StrategyRiskLevel.high:
        return Icons.dangerous_outlined; // Ícone de alto risco
      default:
        return Icons.help_outline; // Risco desconhecido
    }
  }
}