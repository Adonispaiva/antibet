import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:antibet/core/data/api/api_client.dart';
import 'package:antibet/features/journal/services/journal_service.dart';
import 'package:antibet/features/journal/models/journal_entry_model.dart';

// Reutiliza os mocks gerados pelo auth_service_test
import '../../auth/services/auth_service_test.mocks.dart';
    
void main() {
  late MockApiClient mockApiClient;
  late MockFlutterSecureStorage mockSecureStorage;
  late JournalService journalService;

  setUp(() {
    mockApiClient = MockApiClient();
    mockSecureStorage = MockFlutterSecureStorage();
    journalService = JournalService(mockApiClient, mockSecureStorage);
  });

  const tToken = 'fake_token';

  // Mock de uma entrada de diário
  final tJournalEntry = JournalEntryModel(
    id: '1',
    instrument: 'BTC/USD',
    strategyId: 's1',
    direction: 'BUY',
    entryPrice: 50000,
    exitPrice: 51000,
    volume: 1,
    pnl: 1000,
    entryDate: DateTime(2025, 11, 15, 10, 0),
    exitDate: DateTime(2025, 11, 15, 11, 0),
  );

  // Agrupa os testes da funcionalidade de fetchJournalEntries
  group('fetchJournalEntries', () {
    test('deve retornar uma lista de JournalEntryModel se a API responder com sucesso', () async {
      // 1. Arrange
      // Simula o storage lendo o token
      when(mockSecureStorage.read(key: 'authToken')).thenAnswer((_) async => tToken);
      
      // Simula o ApiClient (com o token) buscando as entradas
      when(mockApiClient.get(
        '/journal',
        options: anyNamed('options'), 
      )).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: '/journal'),
        data: [tJournalEntry.toJson()], // Retorna uma lista com o mock
        statusCode: 200,
      ));

      // 2. Act
      final result = await journalService.fetchJournalEntries();

      // 3. Assert
      expect(result, isA<List<JournalEntryModel>>());
      expect(result.length, 1);
      expect(result.first.instrument, 'BTC/USD');
      
      // Verifica se o token foi lido do storage
      verify(mockSecureStorage.read(key: 'authToken'));
      // Verifica se a API foi chamada
      verify(mockApiClient.get('/journal', options: anyNamed('options')));
    });

    test('deve lançar uma exceção se o token não existir no storage', () async {
      // 1. Arrange
      when(mockSecureStorage.read(key: 'authToken')).thenAnswer((_) async => null);

      // 2. Act
      final call = journalService.fetchJournalEntries();

      // 3. Assert
      expect(call, throwsA(isA<Exception>()));
      verifyNever(mockApiClient.get(any, options: anyNamed('options')));
    });
  });

  // Agrupa os testes da funcionalidade de createJournalEntry
  group('createJournalEntry', () {
    test('deve retornar JournalEntryModel se a criação na API for bem-sucedida', () async {
      // 1. Arrange
      when(mockSecureStorage.read(key: 'authToken')).thenAnswer((_) async => tToken);
      
      when(mockApiClient.post(
        '/journal',
        data: tJournalEntry.toJson(), // Envia o modelo
        options: anyNamed('options'), 
      )).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: '/journal'),
        data: tJournalEntry.toJson(), // Retorna o modelo criado (com ID do backend)
        statusCode: 201,
      ));

      // 2. Act
      final result = await journalService.createJournalEntry(tJournalEntry);

      // 3. Assert
      expect(result, isA<JournalEntryModel>());
      expect(result.id, '1');
      verify(mockApiClient.post('/journal', data: tJournalEntry.toJson(), options: anyNamed('options')));
    });
  });
}