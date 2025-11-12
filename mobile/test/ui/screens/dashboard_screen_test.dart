import 'package:antibet/core/notifiers/bet_journal_notifier.dart';
import 'package:antibet/core/notifiers/dashboard_notifier.dart';
import 'package:antibet/core/notifiers/financial_metrics_notifier.dart';
import 'package:antibet/core/notifiers/strategy_recommendation_notifier.dart';
import 'package:antibet/mobile/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Mock classes for critical dependencies used by DashboardScreen
class MockDashboardNotifier extends Mock implements DashboardNotifier {}
class MockFinancialMetricsNotifier extends Mock implements FinancialMetricsNotifier {}
class MockBetJournalNotifier extends Mock implements BetJournalNotifier {}
class MockStrategyRecommendationNotifier extends Mock implements StrategyRecommendationNotifier {}

void main() {
  // Define mock instances
  MockDashboardNotifier mockDashboardNotifier;
  MockFinancialMetricsNotifier mockFinancialMetricsNotifier;
  MockBetJournalNotifier mockBetJournalNotifier;
  MockStrategyRecommendationNotifier mockStrategyRecommendationNotifier;

  // Setup runs before each test
  setUp(() {
    mockDashboardNotifier = MockDashboardNotifier();
    mockFinancialMetricsNotifier = MockFinancialMetricsNotifier();
    mockBetJournalNotifier = MockBetJournalNotifier();
    mockStrategyRecommendationNotifier = MockStrategyRecommendationNotifier();

    // Configure mocks (essential for a clean test state)
    // We assume the Dashboard just observes these notifiers.
    // Real implementation would involve configuring the state (e.g., return specific models).
    when(mockDashboardNotifier.isLoading).thenReturn(false);
    when(mockFinancialMetricsNotifier.metrics).thenReturn(null); // Return initial/mock model
    when(mockBetJournalNotifier.latestEntries).thenReturn([]); // Return empty list or mock data
    when(mockStrategyRecommendationNotifier.recommendation).thenReturn(null); // Return initial/mock model
  });

  // Helper function to pump the widget into the test environment with required providers (SSOT simulation)
  Widget createDashboardScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DashboardNotifier>.value(value: mockDashboardNotifier),
        ChangeNotifierProvider<FinancialMetricsNotifier>.value(value: mockFinancialMetricsNotifier),
        ChangeNotifierProvider<BetJournalNotifier>.value(value: mockBetJournalNotifier),
        ChangeNotifierProvider<StrategyRecommendationNotifier>.value(value: mockStrategyRecommendationNotifier),
        // All Notifiers related to the Dashboard must be present.
      ],
      child: const MaterialApp(
        home: DashboardScreen(),
      ),
    );
  }

  group('DashboardScreen Widget Tests', () {
    testWidgets('DashboardScreen renders successfully and shows key components', (WidgetTester tester) async {
      // Build the DashboardScreen widget.
      await tester.pumpWidget(createDashboardScreen());

      // Wait for all animations and frames to settle.
      await tester.pumpAndSettle();

      // Verification: Check if the main title/label is present.
      expect(find.text('Dashboard'), findsOneWidget);

      // Verification: Check for critical components that should be on the dashboard.
      // 1. Financial Metrics Card (A key component for ROI, Balanço Total, etc.)
      // We assume FinancialMetricsCard uses a distinct key or text. Since we don't have the card's implementation,
      // we'll check for a high-level title or the 'Recommendation Card' which is also mentioned.
      expect(find.text('Financial Metrics'), findsOneWidget); // Assuming a section title exists
      
      // 2. Strategy Recommendation Card (Simulated IA component)
      // The RecommendationCard is likely displayed directly on the Dashboard.
      expect(find.text('Recommendation Rationale'), findsOneWidget); // Assuming text from the card is present
      
      // 3. Loading state check (ensure it is NOT loading after settling)
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    // Future tests:
    // - testWidgets('DashboardScreen shows loading indicator when notifier is loading')
    // - testWidgets('DashboardScreen displays correct financial data')
    // - testWidgets('DashboardScreen displays "No Data" state correctly')
  });
}