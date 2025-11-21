import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:antibet/features/journal/data/models/journal_entry_model.dart';
import 'package:antibet/features/journal/presentation/widgets/journal_entry_item.dart';

void main() {
  group('JournalEntryItem Widget', () {
    final tDate = DateTime(2025, 11, 18);
    
    final winEntry = JournalEntryModel(
      id: '1',
      description: 'Winning Bet',
      amount: 100.0,
      isWin: true,
      date: tDate,
    );

    final lossEntry = JournalEntryModel(
      id: '2',
      description: 'Losing Bet',
      amount: 50.0,
      isWin: false,
      date: tDate,
    );

    testWidgets('should display correct information for a Winning entry', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JournalEntryItem(entry: winEntry),
          ),
        ),
      );

      // Assert
      expect(find.text('Winning Bet'), findsOneWidget);
      expect(find.text('R\$ 100.00'), findsOneWidget);
      expect(find.text('18/11/2025'), findsOneWidget);
      
      // Verifica se o ícone correto (Trending Up) está presente
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
      
      // Verifica a cor (Green) procurando o widget Text com o estilo correto
      final amountText = tester.widget<Text>(find.text('R\$ 100.00'));
      expect(amountText.style?.color, Colors.green);
    });

    testWidgets('should display correct information for a Losing entry', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JournalEntryItem(entry: lossEntry),
          ),
        ),
      );

      // Assert
      expect(find.text('Losing Bet'), findsOneWidget);
      expect(find.text('R\$ 50.00'), findsOneWidget);
      
      // Verifica se o ícone correto (Trending Down) está presente
      expect(find.byIcon(Icons.trending_down), findsOneWidget);
      
      // Verifica a cor (Red)
      final amountText = tester.widget<Text>(find.text('R\$ 50.00'));
      expect(amountText.style?.color, Colors.red);
    });
  });
}