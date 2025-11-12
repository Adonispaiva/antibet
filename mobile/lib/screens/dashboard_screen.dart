import 'package:antibet_mobile/models/dashboard_summary_model.dart';
import 'package:antibet_mobile/notifiers/dashboard_notifier.dart';
import 'package:antibet_mobile/notifiers/financial_metrics_notifier.dart';
import 'package:antibet_mobile/notifiers/strategy_recommendation_notifier.dart'; // Importação Adicionada
import 'package:antibet_mobile/ui/widgets/financial_metrics_card.dart';
import 'package:antibet_mobile/ui/widgets/recommendation_card.dart'; // Importação Adicionada
import 'package:antibet_mobile/ui/widgets/risk_distribution_chart_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Tela do Dashboard (Visão Geral).
///
/// Exibe métricas consolidadas do aplicativo, como taxa de vitória média
/// e contagem de estratégias por risco.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Dispara a ação para carregar o resumo do dashboard na inicialização.
    // Outros notifiers reativos (Financial, Recommendation) são acionados pelo BetJournalNotifier (via main.dart).
    Provider.of<DashboardNotifier>(context, listen: false).loadSummary();
  }

  @override
  Widget build(BuildContext context) {
    // Observa o Notifier para atualizações de estado
    final dashboardNotifier = context.watch<DashboardNotifier>();
    
    // O estado de carregamento deve considerar todos os notifiers essenciais
    final financialNotifier = context.watch<FinancialMetricsNotifier>();
    final recommendationNotifier = context.watch<StrategyRecommendationNotifier>();
    
    final isLoading = notifier.isLoading || financialNotifier.isLoading || recommendationNotifier.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard (Resumo)'),
        // Ação de recarregar
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading
                ? null
                : () => dashboardNotifier.loadSummary(), // Recarrega o DashboardNotifier
          ),
        ],
      ),
      body: _buildBody(context, dashboardNotifier, isLoading),
    );
  }

  Widget _buildBody(BuildContext context, DashboardNotifier notifier, bool isLoading) {
    final financialNotifier = context.watch<FinancialMetricsNotifier>();
    
    // 1. Estado de Carregamento (Inicial)
    if (isLoading && notifier.summary.totalStrategies == 0) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Estado de Erro (Considerando o Dashboard como principal)
    if (notifier.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_outlined, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              notifier.errorMessage ?? 'Falha ao carregar dados.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => notifier.loadSummary(),
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    // 3. Estado de Sucesso (com dados)
    final summary = notifier.summary;
    final metrics = financialNotifier.metrics;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exibe status de carregamento sutil se estiver recarregando
          if (isLoading)
            const LinearProgressIndicator(),
          
          const SizedBox(height: 16),
          
          // --- CARTÃO DE RECOMENDAÇÃO DE IA (NOVO) ---
          const RecommendationCard(),
          
          const SizedBox(height: 24),

          // --- CARTÃO DE MÉTRICAS FINANCEIRAS AVANÇADAS ---
          FinancialMetricsCard(
            metrics: metrics,
            formattedROI: financialNotifier.formattedROI,
          ),
          
          const SizedBox(height: 24),

          // --- Métricas Principais (Win Rate e Total) ---
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildSummaryCard(
                context,
                title: 'Taxa Média de Vitória',
                value: '${summary.averageWinRate.toStringAsFixed(1)}%',
                icon: Icons.trending_up,
                color: Colors.green.shade600,
              ),
              _buildSummaryCard(
                context,
                title: 'Estratégias Totais',
                value: summary.totalStrategies.toString(),
                icon: Icons.category_outlined,
                color: Colors.deepPurple.shade600,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // --- Distribuição de Risco (COMPONENTE AVANÇADO) ---
          RiskDistributionChartCard(summary: summary),
          
          const SizedBox(height: 24),
          
          // --- Outras Métricas ---
          _buildSummaryCard(
            context,
            title: 'Novas Estratégias (Hoje)',
            value: summary.newStrategiesToday.toString(),
            icon: Icons.auto_awesome,
            color: Colors.blue.shade600,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isFullWidth = false,
  }) {
    // Usado para as métricas 2x2 e 1x1
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}