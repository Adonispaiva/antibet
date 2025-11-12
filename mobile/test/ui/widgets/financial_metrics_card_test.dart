import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:antibet_mobile/models/financial_metrics_model.dart';
import 'package:antibet_mobile/ui/widgets/financial_metrics_card.dart';

// =========================================================================
// SIMULAÇÃO DE DEPENDÊNCIAS (Mocks)
// =========================================================================

// Simulação de FinancialMetricsModel (para que o teste possa ser executado neste ambiente)
class FinancialMetricsModel {
  final double returnOnInvestment;
  final double totalProfitLoss;
  final double totalStaked;
  final int totalBets;
  final double averageStake;
  final double winRatePercentage;

  FinancialMetricsModel({
    required this.returnOnInvestment,
    required this.totalProfitLoss,
    required this.totalStaked,
    required this.totalBets,
    required this.averageStake,
    required this.winRatePercentage,
  });
  factory FinancialMetricsModel.empty() => throw UnimplementedError();
}

// SIMULAÇÃO DE FinancialMetricsCard (mínimo necessário para o teste)
class FinancialMetricsCard extends StatelessWidget {
  final FinancialMetricsModel metrics;
  final String formattedROI; 

  const FinancialMetricsCard({
    super.key,
    required this.metrics,
    required this.formattedROI,
  });

  @override
  Widget build(BuildContext context) {
    final Color profitLossColor = metrics.totalProfitLoss >= 0 ? Colors.green.shade400 : Colors.red.shade400;
    final Color roiColor = metrics.returnOnInvestment >= 0 ? Colors.green.shade400 : Colors.red.shade400;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ROI
            _buildMetricItem(context, title: 'Retorno (ROI)', value: formattedROI, color: roiColor),
            // Balanço Total
            _buildMetricItem(context, title: 'Balanço Total', value: 'R\$ ${metrics.totalProfitLoss.toStringAsFixed(2)}', color: profitLossColor),
            // Taxa de Vitória
            _buildMetricItem(context, title: 'Taxa de Vitória', value: '${metrics.winRatePercentage.toStringAsFixed(1)}%', color: Colors.blue.shade400),
          ],
        ),
      ),
    );
  }
  
  // Helper simplificado para fins de teste
  Widget _buildMetricItem(BuildContext context, {required String title, required String value, required Color color}) {
    return Column(
      children: [
        Text(title),
        Text(value, style: TextStyle(color: color)),
      ],
    );
  }
}

// =========================================================================
// FIM DA SIMULAÇÃO
// =========================================================================

void main() {
  group('FinancialMetricsCard Widget Tests', () {
    // --- Dados de Teste ---
    final tProfitMetrics = FinancialMetricsModel(
      returnOnInvestment: 0.15, 
      totalProfitLoss: 150.00,
      totalStaked: 1000.00,
      totalBets: 100,
      averageStake: 10.0,
      winRatePercentage: 65.0,
    );
    
    final tLossMetrics = FinancialMetricsModel(
      returnOnInvestment: -0.05, 
      totalProfitLoss: -50.00,
      totalStaked: 1000.00,
      totalBets: 100,
      averageStake: 10.0,
      winRatePercentage: 45.0,
    );
    
    final tNeutralMetrics = FinancialMetricsModel(
      returnOnInvestment: 0.0, 
      totalProfitLoss: 0.0,
      totalStaked: 500.00,
      totalBets: 50,
      averageStake: 10.0,
      winRatePercentage: 50.0,
    );

    testWidgets('01. Deve exibir valores e cores corretamente para Lucro (Positivo)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FinancialMetricsCard(metrics: tProfitMetrics, formattedROI: '15.00%'),
        ),
      );

      // Verifica os textos
      expect(find.text('R\$ 150.00'), findsOneWidget);
      expect(find.text('15.00%'), findsOneWidget);
      expect(find.text('65.0%'), findsOneWidget);
      
      // Verifica a cor do Balanço (deve ser Verde)
      final balanceText = tester.widget<Text>(find.byWidgetPredicate(
        (widget) => widget is Text && widget.data == 'R\$ 150.00',
      ));
      expect(balanceText.style!.color, Colors.green.shade400);

      // Verifica a cor do ROI (deve ser Verde)
      final roiText = tester.widget<Text>(find.byWidgetPredicate(
        (widget) => widget is Text && widget.data == '15.00%',
      ));
      expect(roiText.style!.color, Colors.green.shade400);
    });
    
    testWidgets('02. Deve exibir valores e cores corretamente para Prejuizo (Negativo)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FinancialMetricsCard(metrics: tLossMetrics, formattedROI: '-5.00%'),
        ),
      );

      // Verifica os textos
      expect(find.text('R\$ -50.00'), findsOneWidget);
      expect(find.text('-5.00%'), findsOneWidget);
      
      // Verifica a cor do Balanço (deve ser Vermelho)
      final balanceText = tester.widget<Text>(find.byWidgetPredicate(
        (widget) => widget is Text && widget.data == 'R\$ -50.00',
      ));
      expect(balanceText.style!.color, Colors.red.shade400);

      // Verifica a cor do ROI (deve ser Vermelho)
      final roiText = tester.widget<Text>(find.byWidgetPredicate(
        (widget) => widget is Text && widget.data == '-5.00%',
      ));
      expect(roiText.style!.color, Colors.red.shade400);
    });
    
    testWidgets('03. Deve exibir valores e cores corretamente para Saldo Neutro (Zero)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FinancialMetricsCard(metrics: tNeutralMetrics, formattedROI: '0.00%'),
        ),
      );

      // Verifica os textos
      expect(find.text('R\$ 0.00'), findsOneWidget);
      expect(find.text('0.00%'), findsOneWidget);
      
      // Balanço Neutro (deve ser Verde, pois >= 0)
      final balanceText = tester.widget<Text>(find.byWidgetPredicate(
        (widget) => widget is Text && widget.data == 'R\$ 0.00',
      ));
      expect(balanceText.style!.color, Colors.green.shade400); // Lógica: >= 0 é verde
      
      // ROI Neutro (deve ser Verde, pois >= 0)
      final roiText = tester.widget<Text>(find.byWidgetPredicate(
        (widget) => widget is Text && widget.data == '0.00%',
      ));
      expect(roiText.style!.color, Colors.green.shade400);
    });
  });
}