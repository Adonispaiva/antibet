import 'package:flutter/material.dart';
import 'package:antibet/src/core/notifiers/dashboard_notifier.dart';

// O Notifier de Gamificação gerencia o estado reativo do progresso do usuário (XP, Nível, Distintivos).

class GamificationNotifier extends ChangeNotifier {
  final DashboardNotifier _dashboardNotifier;
  
  // Constantes de gamificação
  static const int _xpPerGoal = 100;
  static const int _xpPerLevel = 500;
  
  // Variáveis privadas para o estado
  int _currentXP = 0;
  int _currentLevel = 1;
  final List<String> _badges = [];

  GamificationNotifier(this._dashboardNotifier) {
    // Escuta mudanças nas metas para calcular o XP
    _dashboardNotifier.addListener(calculateXPAndLevel);
    
    // Inicia o cálculo do progresso
    calculateXPAndLevel();
  }

  // Getters públicos
  int get currentXP => _currentXP;
  int get currentLevel => _currentLevel;
  List<String> get badges => List.unmodifiable(_badges);
  double get progressToNextLevel => (_currentXP % _xpPerLevel) / _xpPerLevel;

  /// Recalcula o XP e o Nível baseado nas metas concluídas e outros fatores.
  Future<void> calculateXPAndLevel() async {
    // 1. Busca dados do Dashboard
    final goals = _dashboardNotifier.userGoals;
    
    // 2. Cálculo do XP (Fator Metas)
    final completedGoalsCount = goals.where((g) => g.isCompleted).length;
    int newXP = completedGoalsCount * _xpPerGoal;
    
    // 3. Adiciona XP por eventos (Simulação de evento)
    // Se o usuário tem mais de 7 dias sem apostar (Métrica Chave), ganha XP bônus
    if (_currentLevel == 1 && _dashboardNotifier.userGoals.isNotEmpty) { 
        // Lógica real buscaria o dia limpo do Analytics Service.
        newXP += 100; // Bônus de engajamento inicial
    }
    
    // 4. Atualiza Nível
    _currentXP = newXP;
    _currentLevel = (_currentXP ~/ _xpPerLevel) + 1;
    
    // 5. Adquire Distintivos (Simulação de Badging)
    _checkAndAwardBadges(completedGoalsCount);

    notifyListeners();
  }
  
  /// Adquire distintivos com base no progresso.
  void _checkAndAwardBadges(int completedGoalsCount) {
    if (completedGoalsCount >= 5 && !_badges.contains('Mestre das Metas')) {
      _badges.add('Mestre das Metas');
      print('Distintivo Adquirido: Mestre das Metas');
    }
    if (_currentLevel >= 3 && !_badges.contains('Fortaleza Nível 3')) {
      _badges.add('Fortaleza Nível 3');
      print('Distintivo Adquirido: Fortaleza Nível 3');
    }
  }

  // Método de conveniência para ser chamado após um evento de sucesso
  void awardXP(int amount) {
    _currentXP += amount;
    _currentLevel = (_currentXP ~/ _xpPerLevel) + 1;
    _checkAndAwardBadges(_dashboardNotifier.userGoals.where((g) => g.isCompleted).length);
    notifyListeners();
  }
}