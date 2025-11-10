import 'package:flutter/material.dart';
import 'package:antibet/src/core/services/dashboard_service.dart';

// O Notifier gerencia o estado reativo dos dados do Dashboard (Metas, Reflexões).

class DashboardNotifier extends ChangeNotifier {
  final DashboardService _service;
  
  // Variáveis privadas para o estado
  List<Goal> _userGoals = [];
  Reflection? _dailyReflection;
  bool _isLoading = false;

  DashboardNotifier(this._service) {
    // Carrega os dados iniciais na criação do Notifier
    loadDashboardData();
  }

  // Getters públicos para consumo pela UI
  List<Goal> get userGoals => _userGoals;
  Reflection? get dailyReflection => _dailyReflection;
  bool get isLoading => _isLoading;

  /// Carrega as metas e a reflexão diária do serviço.
  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    _userGoals = await _service.loadGoals();
    _dailyReflection = await _service.loadDailyReflection();
    
    _isLoading = false;
    notifyListeners(); 
    
    print('Dashboard Data carregado. Metas: ${_userGoals.length}, Reflexão: ${_dailyReflection?.title}');
  }

  /// Marca uma meta como completa e notifica a UI.
  Future<void> completeGoal(String goalId) async {
    // 1. Chama a lógica de negócio (Service) para persistir (simulado)
    await _service.completeGoal(goalId);
    
    // 2. Atualiza o estado local
    final index = _userGoals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      _userGoals[index] = _userGoals[index].copyWith(isCompleted: true);
    }
    
    // 3. Notifica a UI
    notifyListeners();
  }
}