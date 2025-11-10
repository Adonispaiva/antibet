import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:antibet/src/core/notifiers/dashboard_notifier.dart';
import 'package:antibet/src/core/notifiers/gamification_notifier.dart';
import 'package:antibet/src/core/services/dashboard_service.dart';

// Mocks
class MockDashboardNotifier extends Mock implements DashboardNotifier {
  @override
  List<Goal> get userGoals => super.noSuchMethod(
        Invocation.getter(#userGoals),
        returnValue: [],
      ) as List<Goal>;

  @override
  void addListener(VoidCallback listener) => super.noSuchMethod(Invocation.method(#addListener, [listener]), returnValue: null);
  @override
  void removeListener(VoidCallback listener) => super.noSuchMethod(Invocation.method(#removeListener, [listener]), returnValue: null);
}

void main() {
  late MockDashboardNotifier mockDashboardNotifier;
  late GamificationNotifier notifier;

  // Constantes definidas no GamificationNotifier
  const int xpPerGoal = 100;
  const int xpPerLevel = 500;
  
  // Helper para criar uma lista de metas com um número especificado de concluídas
  List<Goal> createGoalList(int total, int completed) {
    return List.generate(total, (index) {
      return Goal(
        id: 'g$index',
        title: 'Goal $index',
        isCompleted: index < completed,
      );
    });
  }

  setUp(() {
    mockDashboardNotifier = MockDashboardNotifier();
    // Garante que o notifier comece a escutar o dashboard
    notifier = GamificationNotifier(mockDashboardNotifier);
  });
  
  group('GamificationNotifier - XP and Level Calculation', () {
    test('Should calculate XP and level correctly based on completed goals', () async {
      // Setup: 4 metas concluídas
      final goals = createGoalList(5, 4);
      when(mockDashboardNotifier.userGoals).thenReturn(goals);
      
      // Action: Recalcular (chamado automaticamente no setup, mas forçando para o teste)
      await notifier.calculateXPAndLevel();
      
      // XP Esperado: 4 concluídas * 100 XP/meta = 400 XP
      // Mais bônus de engajamento (simulado) = 400 + 100 = 500 XP
      expect(notifier.currentXP, equals(500));
      
      // Nível Esperado: 500 XP / 500 XP/Nível = Nível 2 (começa em 1)
      expect(notifier.currentLevel, equals(2));
      
      // Progresso: 500 XP % 500 = 0.0 (acabou de atingir o novo nível)
      expect(notifier.progressToNextLevel, equals(0.0));
    });

    test('Should handle fractional progress towards the next level', () async {
      // Setup: 6 metas concluídas
      final goals = createGoalList(7, 6);
      when(mockDashboardNotifier.userGoals).thenReturn(goals);
      
      // Action
      await notifier.calculateXPAndLevel();
      
      // XP Esperado: (6 * 100) + 100 (bônus) = 700 XP
      expect(notifier.currentXP, equals(700));
      
      // Nível Esperado: 700 / 500 = 1.4 -> Nível 2
      expect(notifier.currentLevel, equals(2));
      
      // Progresso: (700 % 500) / 500 = 200 / 500 = 0.4
      expect(notifier.progressToNextLevel, equals(0.4));
    });
    
    test('Should award XP directly and update level (awardXP method)', () async {
      // Estado Inicial: Nível 1, XP 100 (apenas do bônus, já que 0 metas foram concluídas)
      when(mockDashboardNotifier.userGoals).thenReturn(createGoalList(0, 0));
      await notifier.calculateXPAndLevel();
      
      expect(notifier.currentLevel, equals(1));
      
      // Ação: Conceder 600 XP diretamente
      notifier.awardXP(600);
      
      // XP Esperado: 100 (inicial) + 600 = 700 XP
      expect(notifier.currentXP, equals(700));
      
      // Nível Esperado: 700 / 500 = Nível 2
      expect(notifier.currentLevel, equals(2));
      
      // Progresso: 700 % 500 / 500 = 0.4
      expect(notifier.progressToNextLevel, equals(0.4));
    });
  });

  group('GamificationNotifier - Badge Acquisition', () {
    test('Should award "Mestre das Metas" badge after 5 goals are completed', () async {
      // Setup: 4 metas concluídas (não é suficiente)
      when(mockDashboardNotifier.userGoals).thenReturn(createGoalList(5, 4));
      await notifier.calculateXPAndLevel();
      expect(notifier.badges, isEmpty);
      
      // Setup: 5 metas concluídas (suficiente)
      when(mockDashboardNotifier.userGoals).thenReturn(createGoalList(6, 5));
      await notifier.calculateXPAndLevel();
      
      // Verificação
      expect(notifier.badges, contains('Mestre das Metas'));
      expect(notifier.badges.length, equals(1));
    });
    
    test('Should award "Fortaleza Nível 3" badge upon reaching level 3', () async {
      // Setup: 10 metas concluídas (1000 XP + 100 bônus = 1100 XP -> Nível 3)
      when(mockDashboardNotifier.userGoals).thenReturn(createGoalList(15, 10));
      
      // Action
      await notifier.calculateXPAndLevel();
      
      // Nível Esperado: 1100 / 500 = Nível 3
      expect(notifier.currentLevel, equals(3));
      
      // Verificação
      expect(notifier.badges, contains('Fortaleza Nível 3'));
      expect(notifier.badges, contains('Mestre das Metas'));
      expect(notifier.badges.length, equals(2));
    });
  });
  
  group('GamificationNotifier - Reactivity', () {
    test('Should call notifyListeners on state change (level up)', () async {
      final listener = MockListener();
      notifier.addListener(listener);

      // Setup: Estado que garante a subida de nível (5 metas)
      when(mockDashboardNotifier.userGoals).thenReturn(createGoalList(5, 5));
      
      // Action: Recalcular
      await notifier.calculateXPAndLevel();
      
      // Verificação: O Listener deve ser notificado
      verify(listener()).called(1);
      
      notifier.removeListener(listener);
    });
  });
}