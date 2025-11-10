import 'package:flutter_test/flutter_test.dart';
import 'package:antibet/src/core/services/dashboard_service.dart';

void main() {
  late DashboardService service;

  setUp(() {
    service = DashboardService();
  });

  group('DashboardService Tests', () {
    test('loadGoals should return a list of goals and check initial status', () async {
      final goals = await service.loadGoals();

      // Verifica se a lista não está vazia
      expect(goals, isNotEmpty);
      
      // Verifica a estrutura e o status inicial da primeira meta
      expect(goals.first.id, equals('g1'));
      expect(goals.first.title, isNotEmpty);
      expect(goals.first.isCompleted, isTrue); // Mock inicial: g1 é true
      
      // Verifica o status de uma meta não completada
      expect(goals[1].isCompleted, isFalse); 
    });

    test('loadDailyReflection should return a valid Reflection object', () async {
      final reflection = await service.loadDailyReflection();
      
      // Verifica se o objeto foi carregado e tem o conteúdo correto
      expect(reflection, isNotNull);
      expect(reflection.title, isNotEmpty);
      expect(reflection.source, isNotEmpty);
      
      // A reflexão deve ser uma das simuladas no serviço
      final validSources = ['Psicoeducação', 'Mindfulness'];
      expect(validSources.contains(reflection.source), isTrue);
    });
    
    test('completeGoal should mark a goal as completed', () async {
      final initialGoals = await service.loadGoals();
      const goalToCompleteId = 'g2'; // Meta inicialmente false

      // Verifica o estado inicial
      expect(initialGoals.firstWhere((g) => g.id == goalToCompleteId).isCompleted, isFalse);

      // Ação: Completar a meta
      await service.completeGoal(goalToCompleteId);
      
      // Recarrega os dados (o mock do serviço mantém o estado na simulação)
      final updatedGoals = await service.loadGoals();

      // Verifica o novo estado
      expect(updatedGoals.firstWhere((g) => g.id == goalToCompleteId).isCompleted, isTrue);
    });

    test('completeGoal should not affect an already completed goal', () async {
      const completedGoalId = 'g1'; // Meta inicialmente true

      // Verifica o estado inicial
      expect(service.loadGoals().then((goals) => goals.firstWhere((g) => g.id == completedGoalId).isCompleted), completion(isTrue));

      // Ação: Tenta completar novamente
      await service.completeGoal(completedGoalId);

      // Recarrega os dados
      final updatedGoals = await service.loadGoals();

      // O estado deve permanecer true
      expect(updatedGoals.firstWhere((g) => g.id == completedGoalId).isCompleted, isTrue);
      // Nenhuma exceção deve ser lançada
    });
  });
}