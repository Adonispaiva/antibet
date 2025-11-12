import 'package:antibet/core/notifiers/bet_strategy_notifier.dart';
import 'package:antibet/mobile/presentation/screens/strategy/strategy_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Mock class for the required dependency
class MockBetStrategyNotifier extends Mock implements BetStrategyNotifier {}

void main() {
  // Define mock instance
  MockBetStrategyNotifier mockBetStrategyNotifier;

  // Setup runs before each test
  setUp(() {
    mockBetStrategyNotifier = MockBetStrategyNotifier();

    // Configure mocks (essential for a clean test state)
    // Assuming the notifier holds a list of strategies
    when(mockBetStrategyNotifier.strategies).thenReturn([]); // Return empty list initially
    when(mockBetStrategyNotifier.isLoading).thenReturn(false);
  });

  // Helper function to pump the widget into the test environment with required providers
  Widget createStrategyScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BetStrategyNotifier>.value(value: mockBetStrategyNotifier),
      ],
      child: const MaterialApp(
        home: StrategyScreen(),
      ),
    );
  }

  group('StrategyScreen Widget Tests', () {
    testWidgets('StrategyScreen renders successfully and shows key elements', (WidgetTester tester) async {
      // Build the StrategyScreen widget.
      await tester.pumpWidget(createStrategyScreen());

      // Wait for all animations and frames to settle.
      await tester.pumpAndSettle();

      // Verification: Check if the AppBar title is present.
      expect(find.text('Strategies'), findsOneWidget);

      // Verification: Check for a key button, like the one to add a new strategy.
      // Assuming there's a FloatingActionButton or a button/icon for adding.
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Verification: Check for the 'No Strategies' message when the list is empty (based on the mock).
      expect(find.text('No strategies found. Tap "+" to add one.'), findsOneWidget);

      // Verification: Ensure the loading indicator is not visible.
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    // Future tests:
    // - testWidgets('StrategyScreen shows list of strategies when available')
    // - testWidgets('StrategyScreen shows loading indicator when notifier is loading')
    // - testWidgets('StrategyScreen navigates to strategy details screen on tap')
  });
}