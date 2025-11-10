import 'package:flutter_test/flutter_test.dart';

// Importações dos componentes a serem testados
import 'package:antibet_mobile/core/domain/bet_strategy_model.dart';
import 'package:antibet_mobile/infra/services/bet_strategy_service.dart';

void main() {
  // Nota: O serviço usa uma lista privada in-memory para simular o backend.
  // Criamos uma nova instância a cada teste para garantir isolamento.
  late BetStrategyService strategyService;
  
  // Estratégia inicial de mock, sem ID
  const BetStrategyModel mockStrategy = BetStrategyModel(
    id: '', 
    name: 'Regra de Teste',
    description: 'Teste de persistência.',
    riskFactor: 0.1,
  );
  
  setUp(() {
    strategyService = BetStrategyService(); 
  });

  group('BetStrategyService CRUD Tests', () {
    
    // --- Teste 1: Fetch Inicial ---
    test('fetchAllStrategies deve retornar a lista inicial de mocks', () async {
      final strategies = await strategyService.fetchAllStrategies();

      // O serviço inicializa com 2 mocks internos
      expect(strategies, isA<List<BetStrategyModel>>());
      expect(strategies, hasLength(2)); 
      expect(strategies.first.name, 'Estratégia Martingale Segura');
    });

    // --- Teste 2: Criação de Nova Estratégia ---
    test('saveStrategy deve criar uma nova estratégia e gerar um ID', () async {
      final strategiesAntes = await strategyService.fetchAllStrategies();
      
      final newStrategy = await strategyService.saveStrategy(mockStrategy);

      // Verifica o ID gerado
      expect(newStrategy.id, isNotEmpty);
      expect(newStrategy.id, startsWith('strat_'));

      // Verifica se a lista cresceu
      final strategiesDepois = await strategyService.fetchAllStrategies();
      expect(strategiesDepois.length, strategiesAntes.length + 1);
      expect(strategiesDepois.last.name, 'Regra de Teste');
    });

    // --- Teste 3: Atualização de Estratégia Existente ---
    test('saveStrategy deve atualizar o nome de uma estratégia existente', () async {
      // Pega a primeira estratégia mockada
      final initialStrategies = await strategyService.fetchAllStrategies();
      final strategyToUpdate = initialStrategies.first;
      
      const newName = 'Regra de Limite Atualizada';
      final updatedModel = strategyToUpdate.copyWith(name: newName);

      final result = await strategyService.saveStrategy(updatedModel);

      // Verifica se o resultado está correto
      expect(result.id, strategyToUpdate.id);
      expect(result.name, newName);

      // Verifica se a atualização foi persistida
      final finalStrategies = await strategyService.fetchAllStrategies();
      expect(finalStrategies.first.name, newName);
      expect(finalStrategies.length, initialStrategies.length); // Tamanho não deve mudar
    });

    // --- Teste 4: Exclusão Bem-Sucedida ---
    test('deleteStrategy deve remover a estratégia da lista', () async {
      final strategiesAntes = await strategyService.fetchAllStrategies();
      final idToDelete = strategiesAntes.first.id;

      await strategyService.deleteStrategy(idToDelete);

      // Verifica se a lista diminuiu
      final strategiesDepois = await strategyService.fetchAllStrategies();
      expect(strategiesDepois.length, strategiesAntes.length - 1);
      expect(strategiesDepois.any((s) => s.id == idToDelete), isFalse);
    });

    // --- Teste 5: Falha de Exclusão (ID Inexistente) ---
    test('deleteStrategy deve lançar BetStrategyException para ID inexistente', () async {
      expect(
        () => strategyService.deleteStrategy('id_inexistente_999'), 
        throwsA(isA<BetStrategyException>()),
      );
    });
    
    // --- Teste 6: Falha na Persistência (Nome Vazio) ---
    test('saveStrategy deve lançar BetStrategyException se o nome for vazio', () async {
      final invalidStrategy = mockStrategy.copyWith(name: ''); 

      expect(
        () => strategyService.saveStrategy(invalidStrategy), 
        throwsA(isA<BetStrategyException>()),
      );
      
      // A lista não deve ter mudado de tamanho
      final strategies = await strategyService.fetchAllStrategies();
      expect(strategies, hasLength(2));
    });
  });
}