import 'package:antibet/core/models/strategy_recommendation_model.dart'; // Assuming the model name
import 'package:antibet/mobile/presentation/widgets/dashboard/recommendation_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Helper function to create a testable card widget
  Widget createRecommendationCard(StrategyRecommendationModel recommendation) {
    return MaterialApp(
      home: Scaffold(
        body: RecommendationCard(recommendation: recommendation),
      ),
    );
  }

  group('RecommendationCard Widget Tests', () {
    testWidgets('Card renders recommendation data correctly', (WidgetTester tester) async {
      // 1. Setup Mock Data for a strong recommendation
      const mockRecommendation = StrategyRecommendationModel(
        id: 'rec-1',
        title: 'High Confidence Strategy',
        rationale: 'Historical data shows strong win rates for similar profiles.',
        confidenceScore: 0.85, // 85%
        recommendedStrategyId: 'S-001',
      );

      // 2. Build the widget
      await tester.pumpWidget(createRecommendationCard(mockRecommendation));
      await tester.pumpAndSettle();

      // 3. Verification: Check for titles, rationale, and score
      
      // Title
      expect(find.text('Strategy Recommendation'), findsOneWidget);
      expect(find.text('High Confidence Strategy'), findsOneWidget);

      // Rationale
      expect(find.text('Rationale'), findsOneWidget);
      expect(find.text('Historical data shows strong win rates for similar profiles.'), findsOneWidget);

      // Confidence Score (assuming percentage formatting)
      expect(find.text('Confidence Score'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget); 
      
      // Verification: Check for a key indicator, like a high confidence icon/color (assuming a star for high confidence)
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('Card renders a low confidence scenario', (WidgetTester tester) async {
      // 1. Setup Mock Data for a low confidence scenario
      const lowConfidenceRecommendation = StrategyRecommendationModel(
        id: 'rec-2',
        title: 'Low Confidence Strategy',
        rationale: 'Insufficient recent data to guarantee success. Proceed with caution.',
        confidenceScore: 0.30, // 30%
        recommendedStrategyId: 'S-005',
      );

      // 2. Build the widget
      await tester.pumpWidget(createRecommendationCard(lowConfidenceRecommendation));
      await tester.pumpAndSettle();

      // 3. Verification: Check for the low score and the corresponding icon (assuming a warning icon for low confidence)
      expect(find.text('Low Confidence Strategy'), findsOneWidget);
      expect(find.text('30%'), findsOneWidget); 
      expect(find.byIcon(Icons.warning), findsOneWidget); 
      expect(find.byIcon(Icons.star), findsNothing);
    });
  });
}