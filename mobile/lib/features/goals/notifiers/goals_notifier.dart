// mobile/lib/features/goals/notifiers/goals_notifier.dart

import 'package:antibet/core/services/goals_service.dart';
import 'package:antibet/features/goals/models/goal_model.dart';
import 'package:flutter/foundation.dart';

/// Notifier responsável por gerenciar e expor a lista de metas do usuário à UI.
class GoalsNotifier extends ChangeNotifier {
  final GoalsService _goalsService;

  // Estado
  List<GoalModel> _goals = [];
  bool _isLoading = false;
  String? _errorMessage;

  GoalsNotifier(this._goalsService) {
    // Carrega as metas na inicialização (auto-load)
    fetchGoals();
  }

  // Getters para a UI
  List<GoalModel> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  /// Obtém a lista de metas do serviço (API) e atualiza o estado.
  Future<void> fetchGoals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _goals = await _goalsService.loadGoals();
      _goals.sort((a, b) => a.targetDate.compareTo(b.targetDate)); // Ordena por data alvo
    } catch (e) {
      _errorMessage = 'Falha ao carregar metas: $e';
      debugPrint('GoalsNotifier Error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adiciona uma nova meta e atualiza a lista no Backend e localmente.
  Future<void> addGoal(GoalModel goal) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Cria no Backend (via Service)
      final newGoal = await _goalsService.createGoal(goal);
      
      // 2. Atualiza o estado local
      _goals.add(newGoal);
      _goals.sort((a, b) => a.targetDate.compareTo(b.targetDate));
      
      debugPrint('GoalsNotifier: Meta adicionada localmente: ${newGoal.title}');
    } catch (e) {
      _errorMessage = 'Falha ao adicionar meta: $e';
      debugPrint('GoalsNotifier Error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Atualiza uma meta existente (ex: progresso, status) e atualiza o Backend.
  Future<void> updateGoal(GoalModel updatedGoal) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Atualiza no Backend (via Service)
      final result = await _goalsService.updateGoal(updatedGoal);
      
      // 2. Atualiza o estado local
      final index = _goals.indexWhere((g) => g.id == updatedGoal.id);
      if (index != -1) {
        _goals[index] = result;
      }
      
      debugPrint('GoalsNotifier: Meta atualizada localmente: ${result.title}');
    } catch (e) {
      _errorMessage = 'Falha ao atualizar meta: $e';
      debugPrint('GoalsNotifier Error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Remove uma meta e atualiza o estado.
  Future<void> removeGoal(int goalId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Remove no Backend (via Service)
      await _goalsService.deleteGoal(goalId);
      
      // 2. Remove do estado local
      _goals.removeWhere((g) => g.id == goalId);
      
      debugPrint('GoalsNotifier: Meta removida localmente: ID $goalId');
    } catch (e) {
      _errorMessage = 'Falha ao remover meta: $e';
      debugPrint('GoalsNotifier Error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}