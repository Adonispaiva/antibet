import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:antibet_app/notifiers/behavioral_analytics_notifier.dart';
import 'package:antibet_app/infra/services/behavioral_analytics_service.dart';

// Gera o mock para o serviço
@GenerateMocks([BehavioralAnalyticsService])
import 'test_behavioral_analytics_notifier.mocks.dart'; 

void main() {
  late MockBehavioralAnalyticsService mockService;
  late BehavioralAnalyticsNotifier notifier;

  setUp(() {
    mockService = MockBehavioralAnalyticsService();
    
    // Comportamento padrão: o serviço sempre retorna o escore atual (mockado)
    when(mockService.getCurrentRiskScore()).thenReturn(0.0); 
    
    // Inicializa o Notifier
    notifier = BehavioralAnalyticsNotifier(mockService);
  });

  group('BehavioralAnalyticsNotifier - Q.R. (Escopo de Risco)', () {
    test('Estado inicial deve ter escore zero e nivel LOW', () {
      expect(notifier.riskScore, 0.0);
      expect(notifier.riskLevel, RiskLevel.low);
    });

    test('calculateAnalytics deve carregar o escore inicial do servico', () async {
      // 1. Arrange: Mocka o servico para retornar um escore inicial de 35.0
      when(mockService.calculateAnalytics()).thenAnswer((_) async => 35.0);
      
      // 2. Act
      await notifier.calculateAnalytics();
      
      // 3. Assert
      expect(notifier.riskScore, 35.0);
      expect(notifier.riskLevel, RiskLevel.low);
    });

    test('trackEvent deve atualizar o escore e notificar listeners', () async {
      // 1. Arrange: Simula o novo escore após o evento
      when(mockService.trackEvent(any)).thenAnswer((_) async {});
      when(mockService.getCurrentRiskScore()).thenReturn(60.0); // Novo escore após o evento
      
      // Captura as notificacoes
      final listener = MockFunction();
      notifier.addListener(listener);
      
      // 2. Act
      await notifier.trackEvent('bet_limit_exceeded');
      
      // 3. Assert
      // Verifica se o metodo de rastreamento do servico foi chamado
      verify(mockService.trackEvent('bet_limit_exceeded')).called(1);
      
      // Verifica se o estado foi atualizado
      expect(notifier.riskScore, 60.0);
      
      // Verifica se a notificacao foi chamada
      verify(listener()).called(1);
    });

    test('Getters: Classificacao de Risco (Low, Medium, High)', () {
      // LOW (< 50)
      when(mockService.getCurrentRiskScore()).thenReturn(49.9);
      notifier = BehavioralAnalyticsNotifier(mockService);
      expect(notifier.riskLevel, RiskLevel.low);

      // MEDIUM (50 a 99.9)
      when(mockService.getCurrentRiskScore()).thenReturn(50.0);
      notifier = BehavioralAnalyticsNotifier(mockService);
      expect(notifier.riskLevel, RiskLevel.medium);
      
      when(mockService.getCurrentRiskScore()).thenReturn(99.9);
      notifier = BehavioralAnalyticsNotifier(mockService);
      expect(notifier.riskLevel, RiskLevel.medium);

      // HIGH (>= 100)
      when(mockService.getCurrentRiskScore()).thenReturn(100.0);
      notifier = BehavioralAnalyticsNotifier(mockService);
      expect(notifier.riskLevel, RiskLevel.high);
    });
  });
}

class MockFunction extends Mock {
  void call();
}