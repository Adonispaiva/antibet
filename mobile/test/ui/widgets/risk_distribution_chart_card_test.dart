import 'package:antibet/core/models/risk_distribution_model.dart'; // Assuming the model name
import 'package:antibet/mobile/presentation/widgets/dashboard/risk_distribution_chart_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Assuming a simplified RiskDataModel for the chart segments
class RiskDataModel {
  final String category;
  final double amount;
  final Color color;

  RiskDataModel(this.category, this.amount, this.color);
}

void main() {
  // Helper function to create a testable card widget
  Widget createRiskDistributionChartCard(List<RiskDataModel> data) {
    return MaterialApp(
      home: Scaffold(
        body: RiskDistributionChartCard(riskData: data),
      ),
    );
  }

  group('RiskDistributionChartCard Widget Tests', () {
    testWidgets('Card renders chart title and data segments', (WidgetTester tester) async {
      // 1. Setup Mock Data for the chart
      final mockRiskData = [
        RiskDataModel('Low Risk', 60.0, Colors.green),
        RiskDataModel('Medium Risk', 30.0, Colors.orange),
        RiskDataModel('High Risk', 10.0, Colors.red),
      ];
      
      // 2. Build the widget
      await tester.pumpWidget(createRiskDistributionChartCard(mockRiskData));
      await tester.pumpAndSettle();

      // 3. Verification: Check for the Card's main title
      expect(find.text('Risk Distribution'), findsOneWidget);

      // 4. Verification: Check for the presence of the chart widget itself.
      // We assume the chart widget is either a custom widget or a known library widget (e.g., PieChart). 
      // We will check for the presence of a generic key or widget type that signifies a chart,
      // or the data labels if they are displayed.
      
      // Assuming a generic placeholder for the chart widget itself (often a custom type or key)
      // Since we don't have the chart lib, we check for data labels which usually render.
      expect(find.text('Low Risk'), findsOneWidget); 
      expect(find.text('Medium Risk'), findsOneWidget);
      expect(find.text('High Risk'), findsOneWidget);

      // Verification: Check if the total amount (100.0) or percentage is implicitly rendered (e.g., 60%, 30%, 10%).
      // We will check for the formatted string '60.0' or related text near the 'Low Risk' category.
      expect(find.textContaining('60.0'), findsOneWidget);
      expect(find.textContaining('30.0'), findsOneWidget);
      expect(find.textContaining('10.0'), findsOneWidget);
    });

    testWidgets('Card renders correctly with no data', (WidgetTester tester) async {
      // 1. Setup Mock Data with an empty list
      final emptyRiskData = <RiskDataModel>[];
      
      // 2. Build the widget
      await tester.pumpWidget(createRiskDistributionChartCard(emptyRiskData));
      await tester.pumpAndSettle();

      // 3. Verification: Check for the title and a placeholder message for missing data.
      expect(find.text('Risk Distribution'), findsOneWidget);
      expect(find.text('No risk data available.'), findsOneWidget); // Assuming a placeholder message
    });
  });
}