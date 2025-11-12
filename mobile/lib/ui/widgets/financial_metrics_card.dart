import 'package:antibet_mobile/models/financial_metrics_model.dart';
import 'package:flutter/material.dart';

/// Componente de Card para exibir as métricas financeiras avançadas.
///
/// Exibe o ROI, o Balanço Total (Lucro/Prejuízo) e a Taxa de Vitória.
class FinancialMetricsCard extends StatelessWidget {
  final FinancialMetricsModel metrics;
  final String formattedROI; // Recebido já formatado do Notifier (para teste de CI)

  const FinancialMetricsCard({
    super.key,
    required this.metrics,
    required this.formattedROI,
  });

  @override
  Widget build(BuildContext context) {
    // Cores baseadas no balanço (Profit/Loss)
    final Color profitLossColor = metrics.totalProfitLoss >= 0 ? Colors.green.shade400 : Colors.red.shade400;
    final Color roiColor = metrics.returnOnInvestment >= 0 ? Colors.green.shade400 : Colors.red.shade400;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Financeira',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // --- Linha 1: ROI e Balanço Total ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricItem(
                  context,
                  title: 'Retorno (ROI)',
                  value: formattedROI,
                  color: roiColor,
                  icon: Icons.ssid_chart,
                ),
                _buildMetricItem(
                  context,
                  title: 'Balanço Total',
                  value: 'R\$ ${metrics.totalProfitLoss.toStringAsFixed(2)}',
                  color: profitLossColor,
                  icon: metrics.totalProfitLoss >= 0 ? Icons.trending_up : Icons.trending_down,
                ),
              ],
            ),
            const Divider(height: 30),
            
            // --- Linha 2: Taxa de Vitória e Total Apostado ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricItem(
                  context,
                  title: 'Taxa de Vitória',
                  value: '${metrics.winRatePercentage.toStringAsFixed(1)}%',
                  color: Colors.blue.shade400,
                  icon: Icons.military_tech,
                ),
                _buildMetricItem(
                  context,
                  title: 'Total Apostado',
                  value: 'R\$ ${metrics.totalStaked.toStringAsFixed(2)}',
                  color: Colors.grey.shade400,
                  icon: Icons.money_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói um item de métrica vertical.
  Widget _buildMetricItem(
    BuildContext context, {
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}