import 'package:antibet/core/models/bet_journal_entry_model.dart'; // Assuming the model name
import 'package:antibet/core/notifiers/bet_journal_notifier.dart';
import 'package:antibet/mobile/presentation/screens/journal/bet_journal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Mock class for the required dependency
class MockBetJournalNotifier extends Mock implements BetJournalNotifier {}

// Helper function to create a mock entry for testing
BetJournalEntryModel createMockEntry(String description, double stake) {
  return BetJournalEntryModel(
    id: UniqueKey().toString(),
    date: DateTime.now(),
    strategyId: 'strategy-x',
    description: description,
    stake: stake,
    result: 'Win', // or Loss/Push
    payout: stake * 2.0,
  );
}

void main() {
  // Define mock instance
  MockBetJournalNotifier mockBetJournalNotifier;

  // Setup runs before each test
  setUp(() {
    mockBetJournalNotifier = MockBetJournalNotifier();

    // Configure mocks (essential for a clean test state)
    // Create some mock data for a scenario where there are entries
    final mockEntries = [
      createMockEntry('Aposta em Futebol', 10.0),
      createMockEntry('Aposta em Basquete', 5.0),
    ];
    
    when(mockBetJournalNotifier.entries).thenReturn(mockEntries);
    when(mockBetJournalNotifier.isLoading).thenReturn(false);
  });

  // Helper function to pump the widget into the test environment with required providers
  Widget createBetJournalScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BetJournalNotifier>.value(value: mockBetJournalNotifier),
      ],
      child: const MaterialApp(
        home: BetJournalScreen(),
      ),
    );
  }

  group('BetJournalScreen Widget Tests', () {
    testWidgets('BetJournalScreen renders successfully and shows entries', (WidgetTester tester) async {
      // Build the BetJournalScreen widget.
      await tester.pumpWidget(createBetJournalScreen());

      // Wait for all animations and frames to settle.
      await tester.pumpAndSettle();

      // Verification: Check if the AppBar title is present.
      expect(find.text('Bet History'), findsOneWidget);

      // Verification: Check if the mock entries are displayed on the screen.
      expect(find.text('Aposta em Futebol'), findsOneWidget);
      expect(find.text('Aposta em Basquete'), findsOneWidget);
      
      // Verification: Check for a key button, like the one to add a new entry.
      // The button/icon is typically on the AppBar or a FloatingActionButton.
      expect(find.byIcon(Icons.add_box), findsOneWidget); // Assuming an appropriate icon for "Add Entry"

      // Verification: Ensure the loading indicator is not visible.
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    // testWidgets('BetJournalScreen shows "No entries" message when list is empty', (WidgetTester tester) async {
    //   // Reconfigure the mock for the empty state
    //   when(mockBetJournalNotifier.entries).thenReturn([]);
      
    //   await tester.pumpWidget(createBetJournalScreen());
    //   await tester.pumpAndSettle();

    //   // Verification: Check for the 'No entries' message (assuming the screen has one).
    //   expect(find.text('No entries found.'), findsOneWidget);
    // });
    
    // Future tests:
    // - testWidgets('BetJournalScreen handles filtering/sorting UI correctly')
    // - testWidgets('BetJournalScreen navigates to entry detail on tap')
  });
}