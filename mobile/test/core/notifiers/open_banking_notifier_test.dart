import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:antibet/src/core/services/open_banking_service.dart';
import 'package:antibet/src/core/notifiers/open_banking_notifier.dart';

// Mocks
class MockOpenBankingService extends Mock implements OpenBankingService {
  @override
  bool get isConnected => super.noSuchMethod(
        Invocation.getter(#isConnected),
        returnValue: false,
      ) as bool;

  @override
  Future<bool> connectToBank() => super.noSuchMethod(
        Invocation.method(#connectToBank, []),
        returnValue: Future.value(false),
      ) as Future<bool>;

  @override
  Future<void> disconnectBank() => super.noSuchMethod(
        Invocation.method(#disconnectBank, []),
        returnValue: Future.value(null),
      ) as Future<void>;

  @override
  Future<double> calculateAccumulatedSavings() => super.noSuchMethod(
        Invocation.method(#calculateAccumulatedSavings, []),
        returnValue: Future.value(5000.00), // Mock de Economia
      ) as Future<double>;

  @override
  Future<double> calculateTotalLosses(DateTime startDate, DateTime endDate) => super.noSuchMethod(
        Invocation.method(#calculateTotalLosses, [startDate, endDate]),
        returnValue: Future.value(500.00), // Mock de Perdas 30d
      ) as Future<double>;
}

// Helper para testar se notifyListeners foi chamado
class MockListener extends Mock {
  void call();
}

void main() {
  late MockOpenBankingService mockService;
  late OpenBankingNotifier notifier;

  setUp(() {
    mockService = MockOpenBankingService();
    notifier = OpenBankingNotifier(mockService);
  });
  
  group('OpenBankingNotifier - Connection Flow', () {
    test('connectBank should set connection state and fetch data on success', () async {
      // Setup: Mock para simular conexão bem-sucedida
      when(mockService.connectToBank()).thenAnswer((_) => Future.value(true));
      
      final listener = MockListener();
      notifier.addListener(listener);

      final success = await notifier.connectBank();

      // Verificações de Conexão e Carregamento
      expect(success, isTrue);
      expect(notifier.isConnected, isTrue);
      expect(notifier.isLoading, isFalse);
      
      // Deve chamar a busca de dados
      verify(mockService.calculateAccumulatedSavings()).called(1);
      
      // Deve notificar listeners no mínimo 3 vezes (loading start, loading end, data fetch)
      verify(listener()).called(greaterThanOrEqualTo(2)); 
      
      notifier.removeListener(listener);
    });

    test('connectBank should fail and not fetch data on service failure', () async {
      // Setup: Mock para simular falha na conexão
      when(mockService.connectToBank()).thenAnswer((_) => Future.value(false));

      final success = await notifier.connectBank();

      // Verificações
      expect(success, isFalse);
      expect(notifier.isConnected, isFalse);
      
      // Não deve chamar a busca de dados
      verifyNever(mockService.calculateAccumulatedSavings());
    });

    test('disconnectBank should reset state and call service', () async {
      // Setup: Simula o estado conectado e com dados
      (notifier as dynamic)._isConnected = true;
      (notifier as dynamic)._accumulatedSavings = 100.0;
      (notifier as dynamic)._totalLossesLast30Days = 50.0;
      
      await notifier.disconnectBank();
      
      // Verificações
      expect(notifier.isConnected, isFalse);
      expect(notifier.accumulatedSavings, equals(0.0));
      expect(notifier.totalLossesLast30Days, equals(0.0));
      verify(mockService.disconnectBank()).called(1);
    });
  });

  group('OpenBankingNotifier - Data Fetching and Metrics', () {
    test('fetchFinancialData should update savings and losses metrics', () async {
      // Setup: Simula o estado conectado
      (notifier as dynamic)._isConnected = true;
      
      await notifier.fetchFinancialData();
      
      // Verificações das métricas mockadas
      expect(notifier.accumulatedSavings, equals(5000.00));
      expect(notifier.totalLossesLast30Days, equals(500.00));
      
      // Verifica se os métodos de cálculo do serviço foram chamados
      verify(mockService.calculateAccumulatedSavings()).called(1);
      verify(mockService.calculateTotalLosses(any, any)).called(1);
    });
    
    test('fetchFinancialData should not run if disconnected', () async {
      // Setup: Estado inicial (desconectado)
      expect(notifier.isConnected, isFalse);
      
      await notifier.fetchFinancialData();
      
      // Não deve chamar os métodos de cálculo
      verifyNever(mockService.calculateAccumulatedSavings());
      expect(notifier.accumulatedSavings, equals(0.0));
    });
  });
}