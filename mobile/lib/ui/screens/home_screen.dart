import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:antibet/core/notifiers/financial_metrics_notifier.dart';
import 'package:antibet/core/notifiers/user_profile_notifier.dart';
import 'package:antibet/ui/widgets/metric_summary_card.dart'; // Importação do widget

/// Tela inicial do aplicativo (Tab 0 da Dashboard).
/// Exibe um resumo das métricas financeiras e saudações.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Consome os notifiers necessários para exibir os dados
    final profileNotifier = Provider.of<UserProfileNotifier>(context);
    final metricsNotifier = Provider.of<FinancialMetricsNotifier>(context);

    // Obtém os dados dos notifiers
    final userName = profileNotifier.profile.name;
    final metrics = metricsNotifier.metrics;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // 1. Saudação ao Usuário
          Text(
            'Olá, $userName!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          const Text('Aqui está o resumo do seu desempenho.'),
          
          const SizedBox(height: 24),

          // 2. Cartões de Métricas Principais (Refatorado)
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
          const Text(
            'Gráfico de Evolução (Em breve)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Container(
            height: 200,
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