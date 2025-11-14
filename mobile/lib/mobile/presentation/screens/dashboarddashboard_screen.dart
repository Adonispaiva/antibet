import 'package:antibet/core/notifiers/bet_journal_notifier.dart';
import 'package:antibet/core/notifiers/dashboard_notifier.dart';
import 'package:antibet/core/notifiers/financial_metrics_notifier.dart';
import 'package:antibet/core/notifiers/strategy_recommendation_notifier.dart';
import 'package:antibet/mobile/presentation/widgets/dashboard/financial_metrics_card.dart';
import 'package:antibet/mobile/presentation/widgets/dashboard/recommendation_card.dart';
import 'package:antibet/mobile/presentation/widgets/dashboard/risk_distribution_chart_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Consome os Notifiers necessários
    final dashboardNotifier = context.watch<DashboardNotifier>();
    final metricsNotifier = context.watch<FinancialMetricsNotifier>();
    final recommendationNotifier = context.watch<StrategyRecommendationNotifier>();
    final journalNotifier = context.watch<BetJournalNotifier>(); // Para dados do diário
    
    // Simula uma lista de dados de risco para o gráfico
    // (Em um cenário real, isso seria fornecido por um Notifier específico ou pelo DashboardNotifier)
    final mockRiskData = [
      RiskDataModel('Low', 55.0, Colors.green.shade600),
      RiskDataModel('Medium', 35.0, Colors.orange.shade600),
      RiskDataModel('High', 10.0, Colors.red.shade600),
    ];

    if (dashboardNotifier.isLoading || metricsNotifier.metrics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de boas-vindas
          Text(
            'Welcome Back, Orion!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // 1. Financial Metrics Card
          if (metricsNotifier.metrics != null)
            FinancialMetricsCard(metrics: metricsNotifier.metrics!),
          const SizedBox(height: 20),
          
          // 2. Strategy Recommendation Card (IA Simulada)
          if (recommendationNotifier.recommendation != null)
            RecommendationCard(recommendation: recommendationNotifier.recommendation!),
          const SizedBox(height: 20),

          // 3. Risk Distribution Chart Card
          const Text(
            'Risk & Strategy Distribution',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          RiskDistributionChartCard(riskData: mockRiskData),
          const SizedBox(height: 20),

          // 4. Latest Journal Entries (Simplesmente uma seção de pré-visualização)
          const Text(
            'Latest Entries',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...journalNotifier.latestEntries.take(3).map((entry) => Card(
            child: ListTile(
              title: Text(entry.description),
              subtitle: Text('Stake: ${entry.stake.toStringAsFixed(2)} | Result: ${entry.result}'),
              trailing: Text(
                '${entry.payout.toStringAsFixed(2)}',
                style: TextStyle(
                  color: entry.result == 'Win' ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )),
          
          if (journalNotifier.latestEntries.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Center(child: Text('No bet history yet. Start tracking your bets!')),
            ),
        ],
      ),
    );
  }
}

// Simulação da classe de dados necessária para o RiskDistributionChartCard
class RiskDataModel {
  final String category;
  final double amount;
  final Color color;

  RiskDataModel(this.category, this.amount, this.color);
}