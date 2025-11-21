import 'package:flutter_test/flutter_test.dart';
import 'package:antibet/features/journal/data/models/journal_entry_model.dart';

void main() {
  group('JournalEntryModel', () {
    final tDate = DateTime.parse('2025-11-18T10:00:00.000');
    final tEntry = JournalEntryModel(
      id: '1',
      description: 'Test Bet',
      amount: 100.0,
      isWin: true,
      date: tDate,
    );

    final tJson = {
      'id': '1',
      'description': 'Test Bet',
      'amount': 100.0,
      'isWin': true,
      'date': '2025-11-18T10:00:00.000',
    };

    test('should return a valid model from JSON', () {
      // Act
      final result = JournalEntryModel.fromJson(tJson);

      // Assert
      expect(result.id, tEntry.id);
      expect(result.description, tEntry.description);
      expect(result.amount, tEntry.amount);
      expect(result.isWin, tEntry.isWin);
      expect(result.date, tEntry.date);
    });

    test('should return a JSON map containing the proper data', () {
      // Act
      final result = tEntry.toJson();

      // Assert
      expect(result, tJson);
    });

    test('copyWith should return a valid model with updated values', () {
      // Act
      final result = tEntry.copyWith(description: 'Updated Bet');

      // Assert
      expect(result.description, 'Updated Bet');
      expect(result.amount, tEntry.amount); // Should remain the same
      expect(result.id, tEntry.id);
    });
  });
}