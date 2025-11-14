// mobile/lib/features/metrics/screens/metrics_dashboard_screen.dart

import 'package:antibet/features/metrics/models/metric_summary_model.dart';
import 'package:antibet/features/metrics/notifiers/metrics_notifier.dart';
import 'package:antibet/widgets/metric_summary_card.dart'; // O Widget Refatorado (Fase 1)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 

class MetricsDashboardScreen extends StatelessWidget {
  const MetricsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta as mudanças no MetricsNotifier
    final metricsNotifier = context.watch<MetricsNotifier>();
    final metrics = metricsNotifier.metrics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Métricas'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => metricsNotifier.fetchMetrics(), // Permite "Puxar para atualizar"
        child: metricsNotifier.isLoading
            ? const Center(child: CircularProgressIndicator())
            : metricsNotifier.errorMessage != null
                ? Center(child: Text('Erro: ${metricsNotifier.errorMessage}'))
                : metrics.isEmpty
                    ? const Center(
                        child: Text('Nenhuma métrica calculada. Adicione entradas no Diário.'),
                      )
                    : _buildMetricsGrid(metrics),
      ),
    );
  }
  
  Widget _buildMetricsGrid(List<MetricSummaryModel> metrics) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 colunas
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2, // Ajuste para o tamanho do card
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        // Usa o Widget reutilizável da Fase 1
        return MetricSummaryCard(
          title: metric.title,
          value: metric.value,
          unit: metric.unit,
          icon: _getIconForMetric(metric.title), // Helper para ícone
          color: _getColorForMetric(metric.value), // Helper para cor
        );
      },
    );
  }

  /// Helper para associar ícones aos títulos das métricas (Simulação)
  IconData _getIconForMetric(String title) {
    switch (title.toLowerCase()) {
      case 'roi (retorno s/ investimento)':
        return Icons.trending_up;
      case 'win rate (taxa de acerto)':
        return Icons.pie_chart;
      case 'lucro total':
        return Icons.attach_money;
      case 'entradas (total)':
        return Icons.list_alt;
      default:
        return Icons.bar_chart;
    }
  }
  
  /// Helper para colorir os cards baseado no valor (Simulação)
  Color _getColorForMetric(String value) {
      if (value.startsWith('-')) {
          return Colors.red.shade700;
      }
      if (value.startsWith('0.0') || value.startsWith('0%')) {
          return Colors.grey.shade600;
      }
      return Colors.green.shade700;
  }
}