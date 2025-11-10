import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:antibet/src/core/services/app_usage_tracker_service.dart';
import 'package:antibet/src/core/notifiers/app_usage_tracker_notifier.dart';

// Mocks
class MockAppUsageTrackerService extends Mock implements AppUsageTrackerService {
  @override
  Future<bool> checkUsagePermission() => super.noSuchMethod(
        Invocation.method(#checkUsagePermission, []),
        returnValue: Future.value(false), // Padrão: permissão negada
      ) as Future<bool>;

  @override
  Future<void> requestUsagePermission() => super.noSuchMethod(
        Invocation.method(#requestUsagePermission, []),
        returnValue: Future.value(null),
      ) as Future<void>;

  @override
  Future<List<AppUsageData>> getUsageData(DateTime start, DateTime end) => super.noSuchMethod(
        Invocation.method(#getUsageData, [start, end]),
        returnValue: Future.value([
          // 1. App de Alto Risco (2 horas)
          AppUsageData(appName: 'blaze.com', timeSpent: const Duration(hours: 2), isHighRisk: true),
          // 2. App de Baixo Risco (1 hora)
          AppUsageData(appName: 'facebook.com', timeSpent: const Duration(hours: 1), isHighRisk: false),
          // 3. App de Alto Risco (30 minutos)
          AppUsageData(appName: 'bet365.com', timeSpent: const Duration(minutes: 30), isHighRisk: true),
        ]),
      ) as Future<List<AppUsageData>>;
}

// Helper para testar se notifyListeners foi chamado
class MockListener extends Mock {
  void call();
}

void main() {
  late MockAppUsageTrackerService mockService;
  late AppUsageTrackerNotifier notifier;

  setUp(() {
    mockService = MockAppUsageTrackerService();
    // O construtor chama checkPermissionStatus()
    notifier = AppUsageTrackerNotifier(mockService);
  });
  
  group('AppUsageTrackerNotifier - Permissions', () {
    test('checkPermissionStatus should update hasPermission state', () async {
      // Setup: Mock para retornar true
      when(mockService.checkUsagePermission()).thenAnswer((_) => Future.value(true));
      
      await notifier.checkPermissionStatus();
      
      expect(notifier.hasPermission, isTrue);
      // Deve tentar buscar os dados logo após a permissão ser concedida
      verify(mockService.getUsageData(any, any)).called(1); 
    });

    test('requestPermission should call the service method and check status again', () async {
      final listener = MockListener();
      notifier.addListener(listener);

      // Setup: Mock para retornar false na primeira checagem e true na segunda
      when(mockService.checkUsagePermission())
          .thenAnswer((_) => Future.value(false))
          .thenAnswer((_) => Future.value(true));
      
      // Ação: Inicia a primeira checagem (resulta em false)
      await notifier.checkPermissionStatus(); 
      expect(notifier.hasPermission, isFalse);

      // Ação: Solicita a permissão (simulação)
      await notifier.requestPermission();
      
      // Verifica se o método de solicitação foi chamado
      verify(mockService.requestUsagePermission()).called(1);
      
      // Verifica se checkPermissionStatus foi chamado novamente (após o delay)
      // O mock foi configurado para retornar true na segunda vez.
      expect(notifier.hasPermission, isTrue);
      
      notifier.removeListener(listener);
    });
  });

  group('AppUsageTrackerNotifier - Data Loading and Metrics', () => {
    test('fetchUsageDataForAnalytics should update state and calculate high risk time', () async {
      // Setup: Mocka a permissão como True para permitir a busca
      when(mockService.checkUsagePermission()).thenAnswer((_) => Future.value(true));
      
      // Chamado implicitamente no construtor, mas chamamos explicitamente para isolar o teste
      await notifier.checkPermissionStatus();
      
      expect(notifier.isLoading, isFalse); // Já deve ter terminado a carga inicial

      final listener = MockListener();
      notifier.addListener(listener);
      
      // Ação: Força o novo fetch
      await notifier.fetchUsageDataForAnalytics();
      
      // 1. Verifica o estado de loading (duas chamadas ao listener: true -> false)
      verify(listener()).called(2);
      expect(notifier.isLoading, isFalse);

      // 2. Verifica se os dados brutos foram carregados (2 + 1)
      expect(notifier.recentUsageData.length, equals(3));
      
      // 3. Verificação da Métrica Chave: totalHighRiskTime
      // Risco Alto: 2 horas (120 min) + 30 minutos = 150 minutos
      const expectedDuration = Duration(minutes: 150);
      expect(notifier.totalHighRiskTime, equals(expectedDuration));
      
      // 4. Verifica se o método do serviço foi chamado
      verify(mockService.getUsageData(any, any)).called(greaterThan(0));

      notifier.removeListener(listener);
    });

    test('totalHighRiskTime should be Duration.zero if no high risk apps are used', () async {
       // Setup: Mock que retorna apenas um app não de risco
       when(mockService.getUsageData(any, any)).thenAnswer((_) => Future.value([
          AppUsageData(appName: 'facebook.com', timeSpent: const Duration(hours: 1), isHighRisk: false),
          AppUsageData(appName: 'instagram.com', timeSpent: const Duration(minutes: 10), isHighRisk: false),
        ]));
        
      when(mockService.checkUsagePermission()).thenAnswer((_) => Future.value(true));
      
      await notifier.checkPermissionStatus();
      await notifier.fetchUsageDataForAnalytics();

      // O tempo total de risco deve ser zero
      expect(notifier.totalHighRiskTime, equals(Duration.zero));
    });

    test('fetchUsageDataForAnalytics should not fetch data if permission is denied', () async {
      // Setup: Permissão negada
      when(mockService.checkUsagePermission()).thenAnswer((_) => Future.value(false));
      
      // Chamado no construtor
      await notifier.checkPermissionStatus();
      
      await notifier.fetchUsageDataForAnalytics();
      
      // Verifica se o método de obtenção de dados nunca foi chamado
      verifyNever(mockService.getUsageData(any, any));
      expect(notifier.recentUsageData, isEmpty);
    });
  });
}