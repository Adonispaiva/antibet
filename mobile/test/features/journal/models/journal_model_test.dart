import 'dart:convert';
import 'package:antibet/features/journal/models/journal_entry_model.dart';
import 'package:antibet/features/journal/models/journal_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tDateTime = DateTime.parse('2025-11-17T10:00:00.000Z');

  // 1. Modelo de Entrada (Entry) para inclusão no Journal
  final tEntryModel = JournalEntryModel(
    id: 'entry1',
    journalId: 'journal1',
    investment: 100.0,
    odds: 2.50,
    returnAmount: 250.0,
    result: BetResult.win,
    platform: 'Bet365',
    description: 'Futebol - Vitoria do Time A',
    createdAt: tDateTime,
  );

  // 2. JSON de Entrada para inclusão no JSON do Journal
  final tEntryJson = tEntryModel.toJson();

  // 3. Modelo de Journal completo
  final tJournalModel = JournalModel(
    id: 'journal1',
    userId: 'user1',
    date: '2025-11-17',
    totalBets: 1,
    totalWins: 1,
    totalLost: 0,
    profit: 150.0,
    entries: [tEntryModel],
  );

  // 4. JSON de Journal completo
  final tJournalJson = {
    'id': 'journal1',
    'userId': 'user1',
    'date': '2025-11-17',
    'totalBets': 1,
    'totalWins': 1,
    'totalLost': 0,
    'profit': 150.0,
    'entries': [tEntryJson], // Lista com o JSON da entrada
  };

  group('JournalModel', () {
    test('deve ser uma subclasse de Equatable', () {
      expect(tJournalModel, isA<JournalModel>());
    });

    group('fromJson', () {
      test('deve retornar um modelo válido quando o JSON é válido', () {
        // Act
        final result = JournalModel.fromJson(tJournalJson);

        // Assert
        expect(result, tJournalModel);
        expect(result.entries.length, 1);
        expect(result.entries.first, tEntryModel);
      });

      test('deve retornar um modelo vazio quando entries é []', () {
        // Arrange
        final emptyJson = Map<String, dynamic>.from(tJournalJson)
          ..['entries'] = [];
        const emptyModel = JournalModel(
          id: 'journal1',
          userId: 'user1',
          date: '2025-11-17',
          totalBets: 1,
          totalWins: 1,
          totalLost: 0,
          profit: 150.0,
          entries: [],
        );
        
        // Act
        final result = JournalModel.fromJson(emptyJson);

        // Assert
        expect(result, emptyModel);
        expect(result.entries, isEmpty);
      });
    });

    group('toJson', () {
      test('deve retornar um Map JSON contendo os dados corretos', () {
        // Act
        final result = tJournalModel.toJson();

        // Assert
        // Usamos deep equality (jsonEncode) para comparar Maps e Listas aninhadas
        expect(jsonEncode(result), jsonEncode(tJournalJson));
      });
    });

    group('factory JournalModel.empty', () {
      test('deve criar um modelo com todos os campos numéricos zerados', () {
        // Act
        final result = JournalModel.empty('2025-11-18', userId: 'user1');

        // Assert
        expect(result.id, '');
        expect(result.date, '2025-11-18');
        expect(result.totalBets, 0);
        expect(result.profit, 0.0);
        expect(result.entries, isEmpty);
      });
    });
  });
}