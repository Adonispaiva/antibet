import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:antibet/core/notifiers/financial_metrics_notifier.dart';
import 'package:antibet/ui/widgets/metric_summary_card.dart'; // Importação do widget

/// Tela responsável por exibir uma análise detalhada das métricas financeiras
/// do usuário (Tab 2 da Dashboard).
class MetricsScreen extends StatelessWidget {
  const MetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Consome o notifier de métricas
    final metricsNotifier = Provider.of<FinancialMetricsNotifier>(context);
    final metrics = metricsNotifier.metrics;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          Text(
            'Análise de Performance',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Métricas principais (Refatorado)
          MetricSummaryCard(
            title: 'Lucro Total',
            value: 'R\$ ${metrics.totalProfit.toStringAsFixed(2)}',
            icon: Icons.attach_money,
            color: metrics.totalProfit >= 0 ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 16),
          MetricSummaryCard(
            title: 'ROI (Retorno s/ Investimento)',
            value: '${(metrics.roi * 100).toStringAsFixed(2)}%',
            icon: Icons.trending_up,
            color: Colors.blueAccent,
          ),
          const SizedBox(height: 16),
          MetricSummaryCard(
            title: 'Taxa de Acerto (Hit Rate)',
            value: '${(metrics.hitRate * 100).toStringAsFixed(2)}%',
            icon: Icons.pie_chart,
            color: Colors.orangeAccent,
          ),
          
          const SizedBox(height: 24),
          
          // Placeholder para Gráficos
          Text(
            'Gráfico de Evolução (Em breve)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Container(
            height: 200,
            width: double.infinity,
            color: Theme.of(context).cardColor.withOpacity(0.5),
            alignment: Alignment.center,
            child: const Text('...'),
          ),
          
          const SizedBox(height: 24),

          // Placeholder para Análise por Estratégia
          Text(
            'Performance por Estratégia (Em breve)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Container(
            height: 150,
            width: double.infinity,
            color: Theme.of(context).cardColor.withOpacity(0.5),
            alignment: Alignment.center,
            child: const Text('...'),
          ),
        ],
      ),
    );
  }

  // O método _buildMetricsCard() foi removido daqui e movido
  // para 'mobile/lib/ui/widgets/metric_summary_card.dart'.
}