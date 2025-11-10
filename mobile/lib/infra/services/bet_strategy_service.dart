import 'dart:async';
import 'dart:math';

// Importação do modelo de Domínio
import '../../core/domain/bet_strategy_model.dart';

/// Classe de exceção personalizada para falhas na operação de Estratégias.
class BetStrategyException implements Exception {
  final String message;
  BetStrategyException(this.message);

  @override
  String toString() => 'BetStrategyException: $message';
}

/// O serviço de Estratégias de Apostas é responsável pelo CRUD
/// (Create, Read, Update, Delete) das estratégias de aposta.
class BetStrategyService {
  
  // SIMULAÇÃO: Lista in-memory para atuar como o 'banco de dados'
  final List<BetStrategyModel> _strategies = [
    const BetStrategyModel(
      id: 'strat_1',
      name: 'Estratégia Martingale Segura',
      description: 'Dobrar a aposta após uma perda, mas com limite de 3x.',
      riskFactor: 0.3,
      isActive: true,
    ),
    const BetStrategyModel(
      id: 'strat_2',
      name: 'Análise de Gols no Intervalo',
      description: 'Focada em jogos com alta taxa de gols no primeiro tempo.',
      riskFactor: 0.75,
      isActive: false,
    ),
  ];

  BetStrategyService();

  /// Simula a busca de todas as estratégias na API/backend.
  Future<List<BetStrategyModel>> fetchAllStrategies() async {
    // Simulação de delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Simulação de erro 10% das vezes
    if (Random().nextDouble() < 0.1) {
      throw BetStrategyException('Falha de conexão com o servidor de estratégias.');
    }
    
    return _strategies;
  }

  /// Simula a gravação (Criação ou Atualização) de uma estratégia.
  Future<BetStrategyModel> saveStrategy(BetStrategyModel strategy) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // --- Lógica de Criação/Atualização Simulada ---
    if (strategy.name.isEmpty) {
      throw BetStrategyException('O nome da estratégia não pode ser vazio.');
    }
    
    final index = _strategies.indexWhere((s) => s.id == strategy.id);
    
    if (index == -1) {
      // Criação (simula novo ID)
      final newId = 'strat_${_strategies.length + 1}';
      final newStrategy = strategy.copyWith(id: newId);
      _strategies.add(newStrategy);
      return newStrategy;
    } else {
      // Atualização
      _strategies[index] = strategy;
      return strategy;
    }
  }

  /// Simula a exclusão de uma estratégia.
  Future<void> deleteStrategy(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final initialLength = _strategies.length;
    _strategies.removeWhere((s) => s.id == id);
    
    if (_strategies.length == initialLength) {
       throw BetStrategyException('Estratégia com ID $id não encontrada para exclusão.');
    }
  }
}