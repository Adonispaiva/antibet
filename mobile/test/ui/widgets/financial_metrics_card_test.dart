import 'package:antibet/core/models/financial_metrics_model.dart'; // Assuming the model name
import 'package:antibet/mobile/presentation/widgets/dashboard/financial_metrics_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Helper function to create a testable card widget
  Widget createFinancialMetricsCard(FinancialMetricsModel metrics) {
    return MaterialApp(
      home: Scaffold(
        body: FinancialMetricsCard(metrics: metrics),
      ),
    );
  }

  group('FinancialMetricsCard Widget Tests', () {
    testWidgets('Card renders metrics correctly for a profitable scenario', (WidgetTester tester) async {
      // 1. Setup Mock Data for a profitable scenario
      const profitableMetrics = FinancialMetricsModel(
        totalBalance: 550.00,
        totalStaked: 1000.00,
        netProfitLoss: 50.00,
        roiPercentage: 5.0, // 50/1000 = 0.05
        winRate: 0.60,
      );

      // 2. Build the widget
      await tester.pumpWidget(createFinancialMetricsCard(profitableMetrics));
      await tester.pumpAndSettle();

      // 3. Verification: Check for titles and formatted values (assuming standard currency and percentage formatting)
      
      // Net Profit/Loss (R$ 50.00)
      expect(find.text('Net Profit'), findsOneWidget);
      expect(find.textContaining('R\$ 50.00'), findsOneWidget);

      // ROI (5.0%)
      expect(find.text('ROI'), findsOneWidget);
      expect(find.textContaining('5.0%'), findsOneWidget); 
      
      // Total Balance (R$ 550.00)
      expect(find.text('Balance'), findsOneWidget);
      expect(find.textContaining('R\$ 550.00'), findsOneWidget);

      // Win Rate (60%)
      expect(find.text('Win Rate'), findsOneWidget);
      expect(find.textContaining('60%'), findsOneWidget);
      
      // Verification: Check if the profit/loss indicator shows a positive trend (e.g., green color or up arrow)
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
      expect(find.byIcon(Icons.trending_down), findsNothing);
    });

    testWidgets('Card renders metrics correctly for a losing scenario', (WidgetTester tester) async {
      // 1. Setup Mock Data for a losing scenario
      const losingMetrics = FinancialMetricsModel(
        totalBalance: 900.00,
        totalStaked: 1000.00,
        netProfitLoss: -100.00,
        roiPercentage: -10.0, // -100/1000 = -0.10
        winRate: 0.40,
      );

      // 2. Build the widget
      await tester.pumpWidget(createFinancialMetricsCard(losingMetrics));
      await tester.pumpAndSettle();

      // 3. Verification: Check for titles and formatted values
      
      // Net Profit/Loss (R$ -100.00)
      expect(find.text('Net Loss'), findsOneWidget); // Assuming text changes based on sign
      expect(find.textContaining('R\$ -100.00'), findsOneWidget);

      // ROI (-10.0%)
      expect(find.text('ROI'), findsOneWidget);
      expect(find.textContaining('-10.0%'), findsOneWidget); 
      
      // Verification: Check if the profit/loss indicator shows a negative trend (e.g., red color or down arrow)
      expect(find.byIcon(Icons.trending_down), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsNothing);
    });
  });
}