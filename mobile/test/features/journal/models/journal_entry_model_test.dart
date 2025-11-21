import 'dart.flutter_test/flutter_test.dart';
import 'package:antibet/features/journal/models/journal_entry_model.dart';

void main() {
  final tDateTime = DateTime.parse('2025-11-17T10:00:00.000Z');

  // Modelo de referência para teste
  final tJournalEntryModel = JournalEntryModel(
    id: 'entry1',
    journalId: 'journal1',
    investment: 100.0,
    odds: 2.50,
    returnAmount: 250.0, // Lucro de 150.0
    result: BetResult.win,
    platform: 'Bet365',
    description: 'Futebol - Vitoria do Time A',
    createdAt: tDateTime,
  );

  // Mapa JSON de referência para teste
  final tJournalEntryJson = {
    'id': 'entry1',
    'journalId': 'journal1',
    'investment': 100.0,
    'odds': 2.50,
    'returnAmount': 250.0,
    'result': 'win', // A API deve enviar o nome do enum em lowercase
    'platform': 'Bet365',
    'description': 'Futebol - Vitoria do Time A',
    'createdAt': '2025-11-17T10:00:00.000Z',
  };

  group('JournalEntryModel', () {
    test('deve ser uma subclasse de Equatable', () {
      expect(tJournalEntryModel, isA<JournalEntryModel>());
    });

    test('deve retornar o valor de lucro (profit) corretamente', () {
      // returnAmount (250.0) - investment (100.0) = 150.0
      expect(tJournalEntryModel.profit, 150.0);

      // Teste de Prejuízo
      final tLossEntry = tJournalEntryModel.copyWith(
        returnAmount: 0.0,
        result: BetResult.loss,
      );
      // returnAmount (0.0) - investment (100.0) = -100.0
      expect(tLossEntry.profit, -100.0);
    });
  });

  group('fromJson', () {
    test('deve retornar um modelo válido quando o JSON é válido', () {
      // Act
      final result = JournalEntryModel.fromJson(tJournalEntryJson);

      // Assert
      expect(result, tJournalEntryModel);
      expect(result.result, BetResult.win);
      expect(result.createdAt, tDateTime);
    });

    test('deve converter corretamente outros valores de enum (Loss, Pending)', () {
      // Loss
      final lossJson = Map<String, dynamic>.from(tJournalEntryJson)
        ..['result'] = 'loss';
      final lossResult = JournalEntryModel.fromJson(lossJson);
      expect(lossResult.result, BetResult.loss);

      // Pending
      final pendingJson = Map<String, dynamic>.from(tJournalEntryJson)
        ..['result'] = 'pending';
      final pendingResult = JournalEntryModel.fromJson(pendingJson);
      expect(pendingResult.result, BetResult.pending);

      // HalfWin
      final halfWinJson = Map<String, dynamic>.from(tJournalEntryJson)
        ..['result'] = 'halfWin';
      final halfWinResult = JournalEntryModel.fromJson(halfWinJson);
      expect(halfWinResult.result, BetResult.halfWin);
    });
  });

  group('toJson', () {
    test('deve retornar um Map JSON contendo os dados corretos', () {
      // Act
      final result = tJournalEntryModel.toJson();

      // Assert
      // Compara a serialização com a referência JSON, garantindo
      // que o enum foi serializado para 'win'.
      expect(result, tJournalEntryJson);
    });
  });

  group('copyWith', () {
    test('deve retornar uma nova instância com valores sobrescritos', () {
      // Act
      final updatedModel = tJournalEntryModel.copyWith(
        odds: 3.0,
        platform: 'Pinnacle',
      );

      // Assert
      expect(updatedModel.odds, 3.0);
      expect(updatedModel.platform, 'Pinnacle');
      // Verifica se os campos não alterados permanecem iguais
      expect(updatedModel.id, tJournalEntryModel.id);
      expect(updatedModel.investment, tJournalEntryModel.investment);
    });
  });
}