import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:antibet/features/goals/models/goal_model.dart';
import 'package:antibet/features/goals/services/goals_service.dart';

/// Provider (Gerenciador de Estado) para o módulo Goals (Metas).
/// Utiliza ChangeNotifier para notificar a UI sobre mudanças de estado (ex: nova meta, carregamento).
@injectable
class GoalsProvider with ChangeNotifier {
  final IGoalsService _goalsService;

  List<GoalModel> _goals = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters para exposição do estado
  List<GoalModel> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  GoalsProvider(this._goalsService);

  /// Carrega todas as metas definidas pelo usuário.
  Future<void> fetchGoals() async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      _goals = await _goalsService.fetchGoals();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Falha ao carregar as metas: ${e.toString()}';
      _goals = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Cria uma nova meta e atualiza o estado.
  Future<void> createGoal(GoalModel goal) async {
    _setLoading(true);

    try {
      final newGoal = await _goalsService.createGoal(goal);
      _goals = [newGoal, ..._goals]; // Adiciona ao início da lista
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Falha ao criar a meta: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Atualiza uma meta existente e atualiza o estado.
  Future<void> updateGoal(GoalModel goal) async {
    _setLoading(true);
    try {
      final updatedGoal = await _goalsService.updateGoal(goal);
      // Substitui a meta antiga pela atualizada
      final index = _goals.indexWhere((g) => g.id == updatedGoal.id);
      if (index != -1) {
        _goals[index] = updatedGoal;
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Falha ao atualizar a meta: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Deleta uma meta e atualiza o estado.
  Future<void> deleteGoal(String goalId) async {
    _setLoading(true);

    try {
      await _goalsService.deleteGoal(goalId);
      _goals.removeWhere((goal) => goal.id == goalId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Falha ao deletar a meta: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}