import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:antibet_app/notifiers/lockdown_notifier.dart';
import 'package:antibet_app/infra/services/lockdown_service.dart';
import 'package:antibet_app/notifiers/behavioral_analytics_notifier.dart';

// Gera os mocks para os servicos
@GenerateMocks([LockdownService, BehavioralAnalyticsNotifier])
import 'test_lockdown_notifier.mocks.dart'; 

// Classe auxiliar para simular o listen
class ListenerMock extends Mock {}

void main() {
  late MockLockdownService mockService;
  late MockBehavioralAnalyticsNotifier mockAnalytics;
  late LockdownNotifier notifier;

  setUp(() {
    mockService = MockLockdownService();
    mockAnalytics = MockBehavioralAnalyticsNotifier();
    
    // Configuração básica do Notifier
    notifier = LockdownNotifier(mockService);
    
    // Configura os mocks do servico
    when(mockService.checkLockdownStatus()).thenAnswer((_) async => null);
    when(mockService.clearLockdown()).thenAnswer((_) async => null);
    when(mockService.activateLockdown()).thenAnswer((_) async => DateTime.now().add(const Duration(hours: 24)));
    when(mockService.saveLockdownEndTime(any)).thenAnswer((_) async => null);
    
    // Configura o mock do Analytics
    when(mockAnalytics.riskLevel).thenReturn(RiskLevel.low);
    when(mockAnalytics.trackEvent(any)).thenAnswer((_) async {});
  });
  
  // Funcao para simular a mudanca de estado do Analytics e notificar
  void simulateRiskChange(RiskLevel newLevel) {
    // 1. Mocka o novo nivel
    when(mockAnalytics.riskLevel).thenReturn(newLevel);
    
    // 2. Chama todos os listeners subscritos ao Analytics
    // O mockito simula a chamada de todos os listeners adicionados
    for (final callback in (mockAnalytics as Mock).getListeners()) {
      callback();
    }
  }


  group('LockdownNotifier - Q.R. (Missão Anti-Vício com Analytics)', () {
    
    test('setAnalyticsNotifier deve inscrever o listener e injetar a dependencia', () {
      // 1. Act
      notifier.setAnalyticsNotifier(mockAnalytics);
      
      // 2. Assert
      // Verifica se o listener foi adicionado ao Analytics
      verify(mockAnalytics.addListener(any)).called(1);
    });
    
    test('checkLockdownStatus deve ativar o bloqueio se o Escore de Risco for HIGH', () async {
      // 1. Arrange: Injeta dependencia
      notifier.setAnalyticsNotifier(mockAnalytics);
      
      // Simula o nivel de risco HIGH
      when(mockAnalytics.riskLevel).thenReturn(RiskLevel.high);
      
      // 2. Act
      final result = await notifier.checkLockdownStatus();
      
      // 3. Assert
      expect(result, isTrue, reason: 'Deve bloquear se o risco for HIGH e nao houver persistencia.');
      expect(notifier.isInLockdown, isTrue);
      // Verifica se o bloqueio automatico foi disparado
      verify(mockService.saveLockdownEndTime(any)).called(1);
      verify(mockAnalytics.trackEvent('lockdown_auto_triggered_high_risk')).called(1);
    });

    test('Lógica Reativa: Deve ativar o bloqueio automaticamente quando o risco mudar para HIGH', () async {
      // 1. Arrange: Injeta dependencia e comeca limpo
      notifier.setAnalyticsNotifier(mockAnalytics);
      
      // 2. Act: Simula a mudanca de LOW para HIGH (o que chama _handleRiskScoreUpdate)
      simulateRiskChange(RiskLevel.high);
      
      // 3. Assert: O estado deve mudar e notificar
      expect(notifier.isInLockdown, isTrue);
      // Verifica se o bloqueio automatico foi disparado
      verify(mockService.saveLockdownEndTime(any)).called(1);
      verify(mockAnalytics.trackEvent('lockdown_auto_triggered_high_risk')).called(1);
    });
    
    test('Lógica Reativa: Nao deve ativar o bloqueio se o risco for MEDIUM', () async {
      // 1. Arrange: Injeta dependencia
      notifier.setAnalyticsNotifier(mockAnalytics);
      
      // 2. Act: Simula a mudanca de LOW para MEDIUM
      simulateRiskChange(RiskLevel.medium);
      
      // 3. Assert: O estado deve permanecer False (LOW/MEDIUM nao bloqueiam automaticamente)
      expect(notifier.isInLockdown, isFalse);
      verifyNever(mockService.saveLockdownEndTime(any));
    });
    
    test('Lógica Manual: activateLockdown deve sempre bloquear e chamar Analytics', () async {
      // 1. Arrange: Injeta dependencia e adiciona listener
      notifier.setAnalyticsNotifier(mockAnalytics);
      final listener = ListenerMock();
      notifier.addListener(listener);

      // 2. Act
      await notifier.activateLockdown();
      
      // 3. Assert
      expect(notifier.isInLockdown, isTrue);
      // Verifica o evento de panico
      verify(mockAnalytics.trackEvent('lockdown_activated')).called(1);
      // Verifica a persistencia de 24h
      verify(mockService.activateLockdown()).called(1); 
      verify(listener()).called(1);
    });
  });
}