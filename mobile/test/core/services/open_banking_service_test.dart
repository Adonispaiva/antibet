import 'package:flutter_test/flutter_test.dart';
import 'package:antibet/src/core/services/open_banking_service.dart';

void main() {
  late OpenBankingService service;

  setUp(() {
    service = OpenBankingService();
  });

  group('OpenBankingService - Connection Flow', () {
    test('connectToBank should set isConnected to true after delay', () async {
      expect(service.isConnected, isFalse);
      
      final success = await service.connectToBank();
      
      expect(success, isTrue);
      expect(service.isConnected, isTrue);
    });

    test('disconnectBank should set isConnected to false', () async {
      // Setup: Conecta primeiro
      await service.connectToBank();
      expect(service.isConnected, isTrue);

      await service.disconnectBank();
      
      expect(service.isConnected, isFalse);
    });
  });

  group('OpenBankingService - Financial Calculations (Simulated Data)', () {
    test('calculateAccumulatedSavings should return a positive, non-zero value', () async {
      // O valor é baseado no mock de R$ 500/mês desde 2025-01-01
      final savings = await service.calculateAccumulatedSavings();
      
      expect(savings, greaterThan(0));
      // Garante que o valor está dentro de uma faixa razoável (apenas para o mock)
      expect(savings, greaterThan(3000)); 
    });
    
    test('fetchTransactions should return data only when connected', () async {
      final startDate = DateTime.now().subtract(const Duration(days: 30));
      final endDate = DateTime.now();
      
      // Caso 1: Desconectado
      expect(await service.fetchTransactions(startDate, endDate), isEmpty);
      
      // Caso 2: Conectado
      await service.connectToBank();
      expect(await service.fetchTransactions(startDate, endDate), isNotEmpty);
      expect(service.fetchTransactions(startDate, endDate).then((list) => list.length), equals(5));
    });

    test('calculateTotalLosses should correctly sum only betting related debits', () async {
      final startDate = DateTime.now().subtract(const Duration(days: 30));
      final endDate = DateTime.now();
      
      // Setup: Conecta
      await service.connectToBank();
      
      final totalLosses = await service.calculateTotalLosses(startDate, endDate);
      
      // O mock tem 3 transações de aposta: -150.00, -300.00, -50.00
      // Soma esperada (absoluta): 500.00
      
      expect(totalLosses, equals(500.00));
    });

    test('calculateTotalLosses should exclude credits and non-betting debits', () async {
      // O cálculo deve ignorar:
      // - Créditos (Salário Inovexa: 5000.00)
      // - Débitos não relacionados a apostas (Pagamento Netflix: -49.90)
      
      final startDate = DateTime.now().subtract(const Duration(days: 30));
      final endDate = DateTime.now();
      
      await service.connectToBank();
      
      final totalLosses = await service.calculateTotalLosses(startDate, endDate);
      
      // Se excluirmos, o resultado ainda deve ser 500.00
      expect(totalLosses, equals(500.00));
    });
  });
}