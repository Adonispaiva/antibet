import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:antibet/features/journal/models/journal_entry_model.dart';
import 'package:antibet/features/journal/providers/journal_provider.dart';
import 'package:antibet/features/journal/services/journal_service.dart';

// Gera o mock para o serviço (em um cenário real, usaria build_runner)
class MockJournalService extends Mock implements JournalService {}

void main() {
  late MockJournalService mockJournalService;
  late ProviderContainer container;

  // Dados de teste
  final entry1 = JournalEntryModel(
    id: '1',
    amount: 50.0,
    description: 'Test Bet 1',
    date: DateTime(2025, 11, 17),
    type: 'bet',
  );

  final entry2 = JournalEntryModel(
    id: '2',
    amount: -20.0,
    description: 'Test Bet 2',
    date: DateTime(2025, 11, 18),
    type: 'bet',
  );

  setUp(() {
    mockJournalService = MockJournalService();
    
    // Configura o container do Riverpod com o mock injetado
    container = ProviderContainer(
      overrides: [
        journalServiceProvider.overrideWithValue(mockJournalService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('JournalNotifier Logic Tests', () {
    test('Estado inicial deve ser Loading', () {
      // O provider inicia carregando os dados (getJournal no construtor)
      // Como getJournal é async, o estado inicial imediato é loading
      final state = container.read(journalProvider);
      expect(state, isA<AsyncLoading>());
    });

    test('getJournal deve carregar lista e atualizar estado para Data', () async {
      // Arrange
      when(mockJournalService.getEntries()).thenAnswer((_) async => [entry1, entry2]);

      // Act - O construtor já chama getJournal, mas precisamos aguardar o futuro
      // Uma forma robusta é ler o notifier e aguardar uma chamada manual ou esperar o event loop
      final notifier = container.read(journalProvider.notifier);
      await notifier.getJournal();

      // Assert
      final state = container.read(journalProvider);
      expect(state, isA<AsyncData>());
      expect(state.value, hasLength(2));
      // Verifica ordenação (mais recente primeiro: entry2 > entry1)
      expect(state.value!.first.id, equals(entry2.id));
    });

    test('createEntry deve adicionar item e recarregar lista', () async {
      // Arrange
      when(mockJournalService.getEntries()).thenAnswer((_) async => [entry1]); // Estado inicial
      when(mockJournalService.createEntry(any)).thenAnswer((_) async => entry2); // Resposta do create
      
      final notifier = container.read(journalProvider.notifier);
      await notifier.getJournal(); // Setup inicial

      // Prepara o mock para a segunda chamada do getJournal (após create)
      when(mockJournalService.getEntries()).thenAnswer((_) async => [entry1, entry2]);

      // Act
      await notifier.createEntry(amount: -20.0, description: 'Test Bet 2');

      // Assert
      verify(mockJournalService.createEntry(any)).called(1);
      // O estado deve ter sido atualizado
      final state = container.read(journalProvider);
      expect(state.value, contains(entry2));
    });

    test('deleteEntry deve remover item do estado (otimista)', () async {
      // Arrange
      // Configura estado inicial com 1 item
      when(mockJournalService.getEntries()).thenAnswer((_) async => [entry1]);
      final notifier = container.read(journalProvider.notifier);
      await notifier.getJournal();

      // Mock do delete
      when(mockJournalService.deleteEntry('1')).thenAnswer((_) async {});

      // Act
      await notifier.deleteEntry('1');

      // Assert
      verify(mockJournalService.deleteEntry('1')).called(1);
      final state = container.read(journalProvider);
      expect(state.value, isEmpty);
    });

    test('Deve tratar erros e emitir AsyncError', () async {
      // Arrange
      when(mockJournalService.getEntries()).thenThrow(Exception('API Error'));

      // Act
      final notifier = container.read(journalProvider.notifier);
      await notifier.getJournal();

      // Assert
      final state = container.read(journalProvider);
      expect(state, isA<AsyncError>());
      expect(state.error.toString(), contains('API Error'));
    });
  });
}