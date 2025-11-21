import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:antibet/features/journal/data/services/journal_service.dart';
import 'package:antibet/features/journal/data/models/journal_model.dart';
import 'package:antibet/features/journal/data/models/journal_entry_model.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late JournalService journalService;

  setUp(() {
    mockDio = MockDio();
    journalService = JournalService(mockDio);
  });

  group('JournalService', () {
    final tEntry = JournalEntryModel(
      id: 'e1',
      description: 'Test Bet',
      amount: 50.0,
      isWin: true,
      date: DateTime.now(),
    );

    final tJournal = JournalModel(
      entries: [tEntry],
      totalInvested: 50.0,
      totalWins: 1,
      totalLosses: 0,
    );

    test('getJournal should return JournalModel on success (200)', () async {
      // Arrange
      when(() => mockDio.get('/journal')).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/journal'),
            statusCode: 200,
            data: tJournal.toJson(),
          ));

      // Act
      final result = await journalService.getJournal();

      // Assert
      expect(result.totalInvested, tJournal.totalInvested);
      expect(result.entries.length, 1);
      verify(() => mockDio.get('/journal')).called(1);
    });

    test('createEntry should return JournalEntryModel on success (201)', () async {
      // Arrange
      when(() => mockDio.post('/journal/entries', data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/journal/entries'),
                statusCode: 201,
                data: tEntry.toJson(),
              ));

      // Act
      final result = await journalService.createEntry(
        tEntry.description,
        tEntry.amount,
        tEntry.isWin,
      );

      // Assert
      expect(result.id, tEntry.id);
      verify(() => mockDio.post('/journal/entries', data: any(named: 'data'))).called(1);
    });

    test('updateEntry should return updated JournalEntryModel on success (200)', () async {
      // Arrange
      final updatedEntry = tEntry.copyWith(description: 'Updated');
      when(() => mockDio.put('/journal/entries/${tEntry.id}', data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/journal/entries/${tEntry.id}'),
                statusCode: 200,
                data: updatedEntry.toJson(),
              ));

      // Act
      final result = await journalService.updateEntry(updatedEntry);

      // Assert
      expect(result.description, 'Updated');
      verify(() => mockDio.put('/journal/entries/${tEntry.id}', data: any(named: 'data'))).called(1);
    });

    test('deleteEntry should complete successfully on success (204)', () async {
      // Arrange
      when(() => mockDio.delete('/journal/entries/${tEntry.id}'))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/journal/entries/${tEntry.id}'),
                statusCode: 204, // No Content
              ));

      // Act & Assert
      await journalService.deleteEntry(tEntry.id);
      verify(() => mockDio.delete('/journal/entries/${tEntry.id}')).called(1);
    });

    test('should throw Exception on network failure', () async {
      // Arrange
      when(() => mockDio.get(any())).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/journal'),
        type: DioExceptionType.connectionTimeout,
      ));

      // Act
      final call = journalService.getJournal;

      // Assert
      expect(() => call(), throwsException);
    });
  });
}