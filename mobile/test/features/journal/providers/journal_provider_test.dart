// ignore_for_file: cascade_invocations

import 'package:antibet/core/errors/failures.dart';
import 'package:antibet/features/journal/models/journal_entry_model.dart';
import 'package:antibet/features/journal/models/journal_model.dart';
import 'package:antibet/features/journal/providers/journal_provider.dart';
import 'package:antibet/features/journal/services/journal_service.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/features/journal/services/journal_service.mocks.dart';

void main() {
  // Mocks
  late MockJournalService mockJournalService;
  late ProviderContainer container;

  // Modelos de Teste
  final tEntryModel = JournalEntryModel(
      id: 'e1',
      journalId: 'j1',
      investment: 10.0,
      odds: 2.0,
      returnAmount: 20.0,
      result: BetResult.win,
      platform: 'X',
      description: 'Aposta Teste',
      createdAt: DateTime(2025, 11, 17));
  final tJournalModel = JournalModel(
    id: '1',
    userId: 'u1',
    date: '2025-11-17',
    totalBets: 1,
    totalWins: 1,
    totalLost: 0,
    profit: 10.0,
    entries: [tEntryModel],
  );
  const tDate = '2025-11-17';

  // Configuração
  setUp(() {
    mockJournalService = MockJournalService();
    // Resetar mocks para garantir que o 'verify' seja preciso
    reset(mockJournalService);
    container = ProviderContainer(
      overrides: [
        journalServiceProvider.overrideWithValue(mockJournalService),
      ],
    );
  });

  // Limpeza
  tearDown(() {
    container.dispose();
  });

  // Helper para ler o estado
  JournalState stateReader() => container.read(journalProvider);

  // Helper para ler o Notifier
  JournalProvider notifierReader() => container.read(journalProvider.notifier);

  test('JournalProvider deve iniciar com JournalInitial', () {
    expect(stateReader(), equals(JournalInitial()));
  });

  group('getJournal', () {
    test(
        'deve transicionar para JournalLoaded e retornar o journal em caso de sucesso',
        () async {
      // Arrange
      when(mockJournalService.getJournal(tDate))
          .thenAnswer((_) async => Right(tJournalModel));

      // Act
      final getJournalFuture = notifierReader().getJournal(tDate);

      // Assert (Loading)
      expect(stateReader(), equals(JournalLoading()));

      // Aguarda a conclusão
      await getJournalFuture;

      // Assert (Final)
      expect(stateReader(), equals(JournalLoaded(journal: tJournalModel)));
      verify(mockJournalService.getJournal(tDate)).called(1);
    });

    test('deve transicionar para JournalError em caso de falha na API',
        () async {
      // Arrange
      final tFailure = ApiFailure(message: 'Erro na API');
      when(mockJournalService.getJournal(tDate))
          .thenAnswer((_) async => Left(tFailure));

      // Act
      final getJournalFuture = notifierReader().getJournal(tDate);

      // Assert (Loading)
      expect(stateReader(), equals(JournalLoading()));

      // Aguarda a conclusão
      await getJournalFuture;

      // Assert (Final)
      expect(stateReader(), equals(JournalError(message: tFailure.message)));
      verify(mockJournalService.getJournal(tDate)).called(1);
    });
  });

  group('createEntry', () {
    final tNewEntry = tEntryModel.copyWith(id: 'e2', description: 'Nova Aposta');

    setUp(() {
      // Pré-condição: O Journal deve estar carregado para simular o fluxo UI
      container.read(journalProvider.notifier).state =
          JournalLoaded(journal: tJournalModel);
      // Mocks para a chamada de criação
      when(mockJournalService.createEntry(any))
          .thenAnswer((_) async => Right(tNewEntry));
    });

    test(
        'deve chamar createEntry e subsequentemente getJournal para atualizar o estado',
        () async {
      // Arrange
      // Mock para a chamada de refresh (getJournal)
      final tRefreshedJournal = tJournalModel.copyWith(
          totalBets: 2, entries: [tNewEntry, tEntryModel]);
      when(mockJournalService.getJournal(tDate))
          .thenAnswer((_) async => Right(tRefreshedJournal));

      // Act
      await notifierReader().createEntry(tNewEntry);

      // Assert
      // 1. Verifica se a criação foi chamada
      verify(mockJournalService.createEntry(tNewEntry)).called(1);
      // 2. Verifica se houve a chamada subsequente para refresh
      verify(mockJournalService.getJournal(tDate)).called(1);
      // 3. Verifica se o estado final é o Journal atualizado
      expect(stateReader(), equals(JournalLoaded(journal: tRefreshedJournal)));
    });

    test('deve retornar JournalError e reverter o estado em caso de falha',
        () async {
      // Arrange
      final tFailure = ApiFailure(message: 'Falha ao salvar');
      when(mockJournalService.createEntry(any))
          .thenAnswer((_) async => Left(tFailure));

      // Act
      await notifierReader().createEntry(tNewEntry);

      // Assert
      // 1. Verifica se o estado voltou ao JournalLoaded (antes de disparar o Error)
      // O provider usa o 'oldState' para reverter antes de disparar o erro.
      expect(stateReader(), isA<JournalError>());
      // 2. Verifica a mensagem de erro
      expect((stateReader() as JournalError).message, tFailure.message);
      // 3. O refresh não deve ser chamado
      verifyNever(mockJournalService.getJournal(any));
    });
  });

  group('deleteEntry', () {
    setUp(() {
      // Pré-condição: O Journal deve estar carregado
      container.read(userProvider.notifier).state =
          JournalLoaded(journal: tJournalModel);
    });

    test(
        'deve chamar deleteEntry e subsequentemente getJournal para atualizar o estado',
        () async {
      // Arrange
      when(mockJournalService.deleteEntry(tEntryModel.id))
          .thenAnswer((_) async => const Right(null));
      
      // Mock para a chamada de refresh (Journal vazio)
      final tEmptyJournal = JournalModel.empty(tDate, userId: 'u1');
      when(mockJournalService.getJournal(tDate))
          .thenAnswer((_) async => Right(tEmptyJournal));

      // Act
      await notifierReader().deleteEntry(tEntryModel.id);

      // Assert
      // 1. Verifica se a exclusão foi chamada
      verify(mockJournalService.deleteEntry(tEntryModel.id)).called(1);
      // 2. Verifica se houve a chamada subsequente para refresh
      verify(mockJournalService.getJournal(tDate)).called(1);
      // 3. Verifica se o estado final é o Journal atualizado
      expect(stateReader(), equals(JournalLoaded(journal: tEmptyJournal)));
    });
  });
}