import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:antibet/features/strategy/models/strategy_model.dart';
import 'package:antibet/features/strategy/services/strategy_service.dart';

/// Provider (Gerenciador de Estado) para o módulo Strategy.
/// Utiliza ChangeNotifier para notificar a UI sobre mudanças de estado (ex: nova estratégia, carregamento).
@injectable
class StrategyProvider with ChangeNotifier {
  final IStrategyService _strategyService;

  List<StrategyModel> _strategies = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters para exposição do estado
  List<StrategyModel> get strategies => _strategies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  StrategyProvider(this._strategyService);

  /// Carrega todas as estratégias de trading do usuário.
  Future<void> fetchStrategies() async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      _strategies = await _strategyService.fetchStrategies();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Falha ao carregar as estratégias: ${e.toString()}';
      _strategies = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Cria uma nova estratégia e atualiza o estado.
  Future<void> createStrategy(StrategyModel strategy) async {
    _setLoading(true);

    try {
      final newStrategy = await _strategyService.createStrategy(strategy);
      _strategies = [newStrategy, ..._strategies]; // Adiciona ao início da lista
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Falha ao criar a estratégia: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Deleta uma estratégia e atualiza o estado.
  Future<void> deleteStrategy(String strategyId) async {
    _setLoading(true);

    try {
      await _strategyService.deleteStrategy(strategyId);
      _strategies.removeWhere((strategy) => strategy.id == strategyId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Falha ao deletar a estratégia: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Função utilitária para centralizar a mudança de estado de loading e notificar
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}