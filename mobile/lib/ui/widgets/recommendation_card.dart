import 'package:antibet_mobile/core/navigation/app_router.dart';
import 'package:antibet_mobile/models/strategy_recommendation_model.dart';
import 'package:antibet_mobile/notifiers/bet_strategy_notifier.dart';
import 'package:antibet_mobile/notifiers/strategy_recommendation_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Componente de Card para exibir a recomendação de estratégia do motor de IA.
///
/// Este widget consome dois notifiers: um para o Racional (Recommendation)
/// e outro para os dados da Estratégia (BetStrategyNotifier).
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Observa o Notifier de Recomendação para o estado e o modelo
    final recommendationNotifier = context.watch<StrategyRecommendationNotifier>();
    final recommendation = recommendationNotifier.recommendation;
    final isLoading = recommendationNotifier.isLoading;
    
    // 2. Apenas lê o Notifier de Estratégias para buscar o nome da estratégia
    final strategies = context.read<BetStrategyNotifier>().strategies;

    // Tenta encontrar a estratégia recomendada na lista
    final recommendedStrategy = strategies.firstWhere(
      (s) => s.id == recommendation.strategyId,
      // Se não encontrar, retorna null (ou uma estratégia vazia se StrategyModel suportasse)
      orElse: () => null,
    );
    
    final String strategyName = recommendedStrategy?.title ?? 'Estratégia Desconhecida';
    final bool canNavigate = recommendedStrategy != null;

    if (isLoading) {
      return const Card(
        child: ListTile(
          leading: CircularProgressIndicator(),
          title: Text('Analisando seu desempenho...'),
          subtitle: Text('O motor de recomendação está processando.'),
        ),
      );
    }
    
    // Se não houver dados, exibe um card básico
    if (recommendation.reasonCode == 'EMPTY' || strategies.isEmpty) {
      return Card(
        color: Colors.grey.shade800,
        child: ListTile(
          leading: const Icon(Icons.info_outline, color: Colors.blueGrey),
          title: const Text('Recomendação de Estratégia'),
          subtitle: Text(recommendation.rationale),
        ),
      );
    }

    // --- Card de Recomendação (Dados Encontrados) ---
    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RECOMENDAÇÃO DO MOTOR DE IA',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            // Título da Estratégia Recomendada
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.star_half_outlined, 
                color: Theme.of(context).colorScheme.secondary, 
                size: 30
              ),
              title: Text(
                strategyName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
              subtitle: Text(
                recommendation.rationale,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Confiança', style: Theme.of(context).textTheme.labelSmall),
                  Text(
                    recommendationNotifier.formattedConfidence,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Botão de Ação
            if (canNavigate)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('VER DETALHES E RISCO'),
                  onPressed: () {
                    // Navega para a tela de detalhes da estratégia encontrada
                    Navigator.of(context).pushNamed(
                      AppRouter.strategyDetailRoute,
                      arguments: recommendedStrategy,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}