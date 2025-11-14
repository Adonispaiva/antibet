import 'package:antibet/core/notifiers/bet_journal_notifier.dart';
import 'package:antibet/mobile/presentation/screens/journal/add_bet_journal_entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Mock class for the required dependency
class MockBetJournalNotifier extends Mock implements BetJournalNotifier {}

void main() {
  // Define mock instance
  MockBetJournalNotifier mockBetJournalNotifier;

  // Setup runs before each test
  setUp(() {
    mockBetJournalNotifier = MockBetJournalNotifier();
  });

  // Helper function to pump the widget into the test environment with required providers
  Widget createAddBetJournalEntryScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BetJournalNotifier>.value(value: mockBetJournalNotifier),
      ],
      child: const MaterialApp(
        home: AddBetJournalEntryScreen(),
      ),
    );
  }

  group('AddBetJournalEntryScreen Widget Tests', () {
    testWidgets('Screen renders form fields correctly', (WidgetTester tester) async {
      // Build the AddBetJournalEntryScreen widget.
      await tester.pumpWidget(createAddBetJournalEntryScreen());

      // Wait for all animations and frames to settle.
      await tester.pumpAndSettle();

      // Verification: Check if the AppBar title is present.
      expect(find.text('Add New Bet Entry'), findsOneWidget);

      // Verification: Check for key input fields that must be present in a journal entry form.
      // Assuming fields like 'Description', 'Stake', 'Result' are present.
      expect(find.byKey(const Key('description_field')), findsOneWidget); 
      expect(find.byKey(const Key('stake_field')), findsOneWidget);
      expect(find.byKey(const Key('result_dropdown')), findsOneWidget); 
      
      // Verification: Check for the submit button.
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Save Entry'), findsOneWidget);
    });
    
    // testWidgets('Screen shows error when required fields are empty on submit', (WidgetTester tester) async {
    //   await tester.pumpWidget(createAddBetJournalEntryScreen());
    //   await tester.pumpAndSettle();
      
    //   // Tap the submit button without filling fields
    //   await tester.tap(find.text('Save Entry'));
    //   await tester.pump(); // Renders the error message
      
    //   // Verification: Assuming a validation error message appears.
    //   expect(find.text('Please enter a description.'), findsOneWidget);
    // });
    
    // testWidgets('Successful submission calls notifier method and navigates back', (WidgetTester tester) async {
    //   await tester.pumpWidget(createAddBetJournalEntryScreen());
    //   await tester.pumpAndSettle();

    //   // Simulate filling the form
    //   await tester.enterText(find.byKey(const Key('description_field')), 'Test Bet');
    //   await tester.enterText(find.byKey(const Key('stake_field')), '10.0');
      
    //   // Mock the BetJournalNotifier.addEntry call
    //   when(mockBetJournalNotifier.addEntry(any)).thenAnswer((_) async => true);
      
    //   // Tap the submit button
    //   await tester.tap(find.text('Save Entry'));
    //   await tester.pumpAndSettle();

    //   // Verification: Check if the notifier's add method was called once
    //   verify(mockBetJournalNotifier.addEntry(any)).called(1);
    // });
  });
}