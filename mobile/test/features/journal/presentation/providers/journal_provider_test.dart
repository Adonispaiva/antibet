import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:antibet/features/journal/data/models/journal_model.dart';
import 'package:antibet/features/journal/data/services/journal_service.dart';
import 'package:antibet/features/journal/presentation/providers/journal_provider.dart';

class MockJournalService extends Mock implements JournalService {}

void main() {
  late MockJournalService mockJournalService;
  late ProviderContainer container;

  setUp(() {
    mockJournalService = MockJournalService();
    container = ProviderContainer(
      overrides: [
        journalServiceProvider.overrideWithValue(mockJournalService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('JournalNotifier', () {
    final tJournal = JournalModel(
      entries: [],
      totalInvested: 0,
      totalWins: 0,
      totalLosses: 0,
    );

    test('initial state is AsyncLoading', () {
      // O estado inicial é disparado imediatamente na criação
      // Mas como getJournal é async, a primeira verificação síncrona pode pegar o loading
      final state = container.read(journalProvider);
      expect(state, isA<AsyncLoading>());
    });

    test('getJournal success updates state to AsyncData', () async {
      // Arrange
      when(() => mockJournalService.getJournal()).thenAnswer((_) async => tJournal);

      // Act
      // O notifier chama getJournal no construtor, então aguardamos o future
      final notifier = container.read(journalProvider.notifier);
      await notifier.getJournal();

      // Assert
      final state = container.read(journalProvider);
      expect(state, isA<AsyncData<JournalModel>>());
      expect(state.value, tJournal);
    });

    test('createEntry success triggers refresh', () async {
      // Arrange
      when(() => mockJournalService.getJournal()).thenAnswer((_) async => tJournal);
      when(() => mockJournalService.createEntry(any(), any(), any()))
          .thenAnswer((_) async => tJournal.entries.firstOrNull ?? any()); // Mock do retorno

      final notifier = container.read(journalProvider.notifier);

      // Act
      final result = await notifier.createEntry('Test Bet', 50.0, true);

      // Assert
      expect(result, true);
      // Verifica se o getJournal foi chamado novamente para atualizar a lista
      verify(() => mockJournalService.getJournal()).called(greaterThan(1));
    });

    test('deleteEntry failure returns false', () async {
      // Arrange
      when(() => mockJournalService.deleteEntry(any()))
          .thenThrow(Exception('Delete failed'));

      final notifier = container.read(journalProvider.notifier);

      // Act
      final result = await notifier.deleteEntry('123');

      // Assert
      expect(result, false);
    });
  });
}