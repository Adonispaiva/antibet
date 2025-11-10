import 'package:flutter_test/flutter_test.dart';
import 'package:antibet_app/infra/services/behavioral_analytics_service.dart';

void main() {
  late BehavioralAnalyticsService analyticsService;

  setUp(() {
    // Inicializa o serviço para cada teste
    analyticsService = BehavioralAnalyticsService();
  });

  group('BehavioralAnalyticsService - Q.R. (Escopo de Risco)', () {
    
    test('Estado inicial deve ter um escore de risco zero', () {
      expect(analyticsService.getCurrentRiskScore(), 0.0);
    });

    test('calculateAnalytics deve retornar o escore atual (0.0 no inicio)', () async {
      final initialScore = await analyticsService.calculateAnalytics();
      expect(initialScore, 0.0);
    });

    test('trackEvent: Deve acumular corretamente o escore para eventos conhecidos', () async {
      // Valor do evento 'high_frequency_bet' no serviço: 20.0
      await analyticsService.trackEvent('high_frequency_bet');
      
      // Valor do evento 'bet_limit_exceeded' no serviço: 50.0
      await analyticsService.trackEvent('bet_limit_exceeded');
      
      // Escore esperado: 20.0 + 50.0 = 70.0
      expect(analyticsService.getCurrentRiskScore(), 70.0);
      
      // Verifica o calculo de analytics
      final currentScore = await analyticsService.calculateAnalytics();
      expect(currentScore, 70.0);
    });
    
    test('trackEvent: Deve ignorar eventos desconhecidos e manter o escore', () async {
      // 1. Arrange: Faz um evento conhecido para ter um score inicial
      await analyticsService.trackEvent('high_frequency_bet'); // Score: 20.0
      
      // 2. Act: Tenta registrar um evento que não está no mapa
      await analyticsService.trackEvent('unknown_event_xpto');
      
      // 3. Assert: O escore deve permanecer inalterado
      expect(analyticsService.getCurrentRiskScore(), 20.0);
    });

    test('trackEvent: Deve registrar o evento de maior risco (lockdown_activated)', () async {
      // Valor do evento 'lockdown_activated' no serviço: 100.0
      await analyticsService.trackEvent('lockdown_activated');
      
      expect(analyticsService.getCurrentRiskScore(), 100.0);
    });
  });
}