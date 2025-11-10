import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:antibet/src/core/services/dashboard_service.dart';
import 'package:antibet/src/core/notifiers/dashboard_notifier.dart';

// Mock do DashboardService
class MockDashboardService extends Mock implements DashboardService {
  @override
  Future<List<Goal>> loadGoals() => super.noSuchMethod(
        Invocation.method(#loadGoals, []),
        returnValue: Future.value([
          Goal(id: 'g1', title: 'Meta 1', isCompleted: false),
          Goal(id: 'g2', title: 'Meta 2', isCompleted: true),
        ]),
      ) as Future<List<Goal>>;

  @override
  Future<Reflection> loadDailyReflection() => super.noSuchMethod(
        Invocation.method(#loadDailyReflection, []),
        returnValue: Future.value(Reflection(title: 'Reflexão Mock', content: 'Conteúdo Mock', source: 'TCC')),
      ) as Future<Reflection>;

  @override
  Future<void> completeGoal(String goalId) => super.noSuchMethod(
        Invocation.method(#completeGoal, [goalId]),
        returnValue: Future.value(null),
      ) as Future<void>;
}

void main() {
  late MockDashboardService mockService;
  late DashboardNotifier notifier;

  setUp(() {
    mockService = MockDashboardService();
    // Inicializa o Notifier. O construtor chama loadDashboardData().
    notifier = DashboardNotifier(mockService);
  });
  
  group('DashboardNotifier - Initialization and Data Loading', () {
    test('loadDashboardData should load data, set goals/reflection, and clear isLoading', () async {
      // 1. Antes da execução (chamado no construtor)
      expect(notifier.isLoading, isTrue);

      // Espera a conclusão do Future de carregamento
      await Future.microtask(() {}); 
      
      // 2. Verifica a chamada dos serviços
      verify(mockService.loadGoals()).called(1);
      verify(mockService.loadDailyReflection()).called(1);

      // 3. Verifica o estado final
      expect(notifier.isLoading, isFalse);
      expect(notifier.userGoals.length, equals(2));
      expect(notifier.dailyReflection?.title, equals('Reflexão Mock'));
    });
    
    test('loadDashboardData should notify listeners twice (start and end)', () async {
      final listener = MockListener();
      notifier.addListener(listener);

      // Ação: Chama explicitamente para verificar as notificações
      await notifier.loadDashboardData();

      // Verifica se notifyListeners foi chamado no início (isLoading = true) e no fim (isLoading = false)
      verify(listener()).called(2);
      
      notifier.removeListener(listener);
    });
  });

  group('DashboardNotifier - Goal Completion', () {
    test('completeGoal should call service, update local state, and notify listeners', () async {
      // Garante que os dados foram carregados primeiro
      await Future.microtask(() {}); 
      
      final goalToCompleteId = 'g1'; // Meta inicialmente false (no mock)
      
      // 1. Verifica o estado inicial (Mock é false)
      expect(notifier.userGoals.firstWhere((g) => g.id == goalToCompleteId).isCompleted, isFalse);

      final listener = MockListener();
      notifier.addListener(listener);

      // Ação
      await notifier.completeGoal(goalToCompleteId);

      // 2. Verifica a chamada do serviço
      verify(mockService.completeGoal(goalToCompleteId)).called(1);

      // 3. Verifica o estado local atualizado
      expect(notifier.userGoals.firstWhere((g) => g.id == goalToCompleteId).isCompleted, isTrue);
      
      // 4. Verifica a notificação
      verify(listener()).called(1);
      
      notifier.removeListener(listener);
    });
    
    test('completeGoal should not change state if goalId is not found', () async {
      // Garante que os dados foram carregados primeiro
      await Future.microtask(() {}); 
      
      final listener = MockListener();
      notifier.addListener(listener);
      
      // Ação com ID inválido
      await notifier.completeGoal('invalid_id');
      
      // O service é chamado, mas não deve haver notificação local
      verify(mockService.completeGoal('invalid_id')).called(1);
      verifyNever(listener());
      
      notifier.removeListener(listener);
    });
  });
}

// Helper para testar se notifyListeners foi chamado
class MockListener extends Mock {
  void call();
}