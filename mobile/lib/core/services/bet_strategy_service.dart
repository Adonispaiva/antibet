import 'package:antibet/core/models/bet_strategy_model.dart';
import 'package:antibet/core/services/storage_service.dart';

class BetStrategyService {
  final StorageService _storageService;
  static const String _strategiesKey = 'bet_strategies';

  BetStrategyService(this._storageService);

  /// Carrega todas as estratégias de aposta do armazenamento.
  /// Retorna uma lista vazia se não houver dados.
  List<BetStrategyModel> loadStrategies() {
    return _storageService.loadList<BetStrategyModel>(
      _strategiesKey,
      BetStrategyModel.fromJson,
    );
  }

  /// Salva uma nova estratégia e a persiste no armazenamento.
  Future<bool> saveStrategy(BetStrategyModel newStrategy) async {
    // 1. Carrega a lista atual
    final currentStrategies = loadStrategies();
    
    // 2. Verifica se já existe (para evitar duplicidade se o ID for o mesmo)
    final existingIndex = currentStrategies.indexWhere((s) => s.id == newStrategy.id);
    
    final updatedStrategies = List<BetStrategyModel>.from(currentStrategies);

    if (existingIndex != -1) {
      // Atualiza a estratégia existente
      updatedStrategies[existingIndex] = newStrategy;
    } else {
      // Adiciona a nova estratégia
      updatedStrategies.add(newStrategy);
    }
    
    // 3. Salva a lista atualizada
    return await _storageService.saveList<BetStrategyModel>(
      _strategiesKey,
      updatedStrategies,
      (strategy) => strategy.toJson(),
    );
  }

  /// Remove uma estratégia existente.
  Future<bool> removeStrategy(String strategyId) async {
    final currentStrategies = loadStrategies();
    final updatedStrategies = currentStrategies.where((s) => s.id != strategyId).toList();
    
    return await _storageService.saveList<BetStrategyModel>(
      _strategiesKey,
      updatedStrategies,
      (strategy) => strategy.toJson(),
    );
  }
}