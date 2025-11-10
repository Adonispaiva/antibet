import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Importações dos componentes a serem testados e dependências
import 'package:antibet_mobile/core/domain/bet_strategy_model.dart';
import 'package:antibet_mobile/infra/services/bet_strategy_service.dart';
import 'package:antibet_mobile/notifiers/bet_strategy_notifier.dart';

// Gera o mock para a dependência
@GenerateMocks([BetStrategyService])
import 'bet_strategy_notifier_test.mocks.dart'; 

void main() {
  late MockBetStrategyService mockStrategyService;
  late BetStrategyNotifier strategyNotifier;

  const BetStrategyModel strategy1 = BetStrategyModel(
    id: 's1',
    name: 'Estratégia Teste 1',
    description: 'Desc',
    riskFactor: 0.5,
  );
  const BetStrategyModel newStrategy = BetStrategyModel(
    id: 'new',
    name: 'Nova Estratégia',
    description: 'Novo item',
    riskFactor: 0.2,
  );
  const BetStrategyException serviceError = BetStrategyException('Falha de conexão com a API.');

  // Configuração executada antes de cada teste
  setUp(() {
    mockStrategyService = MockBetStrategyService();
    // Injeta o mock
    strategyNotifier = BetStrategyNotifier(mockStrategyService); 
  });

  // Limpeza executada após cada teste
  tearDown(() {
    reset(mockStrategyService);
  });

  group('BetStrategyNotifier - Fetch Strategies', () {
    // --- Teste 1: Estado Inicial ---
    test('Estado inicial é StrategyState.initial e lista está vazia', () {
      expect(strategyNotifier.state, StrategyState.initial);
      expect(strategyNotifier.strategies, isEmpty);
    });

    // --- Teste 2: Carregamento Bem-Sucedido ---
    test('fetchStrategies: sucesso carrega lista e muda estado para loaded', () async {
      final List<BetStrategyModel> mockList = [strategy1];
      // Configuração: Serviço retorna a lista
      when(mockStrategyService.fetchAllStrategies()).thenAnswer((_) async => mockList);
      
      await strategyNotifier.fetchStrategies();

      // Verifica as transições de estado
      expect(strategyNotifier.state, StrategyState.loaded);
      expect(strategyNotifier.strategies, hasLength(1));
      expect(strategyNotifier.strategies.first.name, 'Estratégia Teste 1');
      
      verify(mockStrategyService.fetchAllStrategies()).called(1);
    });

    // --- Teste 3: Carregamento Mal-Sucedido ---
    test('fetchStrategies: falha define erro e muda estado para error', () async {
      // Configuração: Serviço lança erro
      when(mockStrategyService.fetchAllStrategies()).thenThrow(serviceError);
      
      await strategyNotifier.fetchStrategies();

      // Verifica o estado final
      expect(strategyNotifier.state, StrategyState.error);
      expect(strategyNotifier.strategies, isEmpty);
      expect(strategyNotifier.errorMessage, contains('Falha ao carregar estratégias'));
      
      verify(mockStrategyService.fetchAllStrategies()).called(1);
    });
  });

  group('BetStrategyNotifier - Persistence (Save/Delete)', () {
    // Prepara o notifier com dados carregados antes dos testes de persistência
    setUp(() async {
      final List<BetStrategyModel> mockList = [strategy1];
      when(mockStrategyService.fetchAllStrategies()).thenAnswer((_) async => mockList);
      await strategyNotifier.fetchStrategies(); 
      reset(mockStrategyService); // Limpa interações de fetch
    });

    // --- Teste 4: Criação (Save) Bem-Sucedida ---
    test('saveStrategy: sucesso adiciona item à lista e mantém estado loaded', () async {
      // Configuração: Serviço retorna o novo item (com ID gerado)
      when(mockStrategyService.saveStrategy(newStrategy)).thenAnswer((_) async => newStrategy);
      
      await strategyNotifier.saveStrategy(newStrategy);

      // Verifica o estado local
      expect(strategyNotifier.state, StrategyState.loaded);
      expect(strategyNotifier.strategies, hasLength(2));
      expect(strategyNotifier.strategies.last.name, 'Nova Estratégia');
      
      verify(mockStrategyService.saveStrategy(newStrategy)).called(1);
    });
    
    // --- Teste 5: Exclusão (Delete) Bem-Sucedida ---
    test('deleteStrategy: sucesso remove item da lista', () async {
      // Configuração: Serviço não lança erro
      when(mockStrategyService.deleteStrategy('s1')).thenAnswer((_) async {});
      
      await strategyNotifier.deleteStrategy('s1');

      // Verifica o estado local
      expect(strategyNotifier.state, StrategyState.loaded);
      expect(strategyNotifier.strategies, isEmpty);
      
      verify(mockStrategyService.deleteStrategy('s1')).called(1);
    });
    
    // --- Teste 6: Falha na Persistência (Item não deve ser adicionado/removido) ---
    test('saveStrategy: falha não adiciona item à lista e lança exceção', () async {
      // Configuração: Serviço lança erro
      when(mockStrategyService.saveStrategy(newStrategy)).thenThrow(serviceError);

      // Deve lançar a exceção para que a UI possa reagir
      expect(() => strategyNotifier.saveStrategy(newStrategy), throwsA(isA<BetStrategyException>()));

      // Verifica o estado local: a lista não deve ter mudado
      expect(strategyNotifier.strategies, hasLength(1)); 
    });
  });
}