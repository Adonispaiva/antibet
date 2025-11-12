import 'package:antibet_mobile/models/dashboard_summary_model.dart';
import 'package:flutter/material.dart';

/// Componente de Card para exibir a distribuição de risco das estratégias.
///
/// Este widget recebe o DashboardSummaryModel e exibe o resumo de risco.
/// O espaço do gráfico (Pie Chart) é simulado para futura implementação.
class RiskDistributionChartCard extends StatelessWidget {
  final DashboardSummaryModel summary;

  const RiskDistributionChartCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribuição de Risco das Estratégias',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // --- Área do Gráfico (Simulação) ---
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade800,
                  border: Border.all(color: Colors.grey.shade700, width: 2),
                ),
                child: Center(
                  child: Text(
                    'Gráfico Aqui',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Legendas de Risco ---
            _buildRiskLegend(
              context,
              'Baixo Risco',
              summary.lowRiskStrategies,
              Colors.green,
            ),
            _buildRiskLegend(
              context,
              'Médio Risco',
              summary.mediumRiskStrategies,
              Colors.orange,
            ),
            _buildRiskLegend(
              context,
              'Alto Risco',
              summary.highRiskStrategies,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói um item de legenda para a distribuição de risco.
  Widget _buildRiskLegend(
      BuildContext context, String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.fiber_manual_record, size: 12, color: color),
              const SizedBox(width: 8),
              Text(label, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}