import 'package:antibet_mobile/models/strategy_model.dart';
import 'package:flutter/material.dart';

/// Tela de Detalhes da Estratégia.
///
/// Exibe informações detalhadas sobre um [StrategyModel] específico.
/// Esta tela é 'Stateless' e recebe o modelo via construtor.
class StrategyDetailScreen extends StatelessWidget {
  final StrategyModel strategy;

  const StrategyDetailScreen({super.key, required this.strategy});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(strategy.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Título Principal ---
            Text(
              strategy.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            
            // --- Métricas Principais (Risco e Winrate) ---
            _buildMetricsRow(context),
            const Divider(height: 32, thickness: 1),

            // --- Descrição ---
            Text(
              'Descrição da Estratégia',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              strategy.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // --- Data da Análise ---
            if (strategy.lastAnalyzed != null)
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Última análise: ${strategy.lastAnalyzed!.toLocal().day}/${strategy.lastAnalyzed!.toLocal().month}/${strategy.lastAnalyzed!.toLocal().year}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            
            // TODO: Adicionar gráficos ou dados de backtest se disponível
          ],
        ),
      ),
    );
  }

  /// Constrói a linha de métricas (Risco e Taxa de Vitória).
  Widget _buildMetricsRow(BuildContext context) {
    final riskData = _getRiskData(strategy.riskLevel, context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // --- Nível de Risco ---
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NÍVEL DE RISCO',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(riskData['icon'] as IconData, color: riskData['color'] as Color),
                  const SizedBox(width: 8),
                  Text(
                    riskData['text'] as String,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: riskData['color'] as Color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // --- Taxa de Vitória ---
        if (strategy.winRatePercentage != null)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'TAXA DE VITÓRIA',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${strategy.winRatePercentage!.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.green.shade300,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Helper para retornar dados de UI (Texto, Cor, Ícone) com base no Risco.
  Map<String, dynamic> _getRiskData(StrategyRiskLevel risk, BuildContext context) {
    switch (risk) {
      case StrategyRiskLevel.low:
        return {
          'text': 'Baixo',
          'icon': Icons.check_circle_outline,
          'color': Colors.green.shade400,
        };
      case StrategyRiskLevel.medium:
        return {
          'text': 'Médio',
          'icon': Icons.warning_amber_rounded,
          'color': Colors.orange.shade400,
        };
      case StrategyRiskLevel.high:
        return {
          'text': 'Alto',
          'icon': Icons.dangerous_outlined,
          'color': Colors.red.shade400,
        };
      default:
        return {
          'text': 'N/D',
          'icon': Icons.help_outline,
          'color': Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
        };
    }
  }
}