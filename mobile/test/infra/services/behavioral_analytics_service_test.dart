import 'package:flutter_test/flutter_test.dart';

// Importações dos componentes a serem testados
import 'package:antibet_mobile/core/domain/behavioral_analytics_model.dart';
import 'package:antibet_mobile/infra/services/behavioral_analytics_service.dart';

void main() {
  late BehavioralAnalyticsService analyticsService;
  
  setUp(() {
    // Instancia o serviço
    analyticsService = BehavioralAnalyticsService(); 
  });

  group('BehavioralAnalyticsService Tests (Missão Anti-Vício)', () {
    
    // --- Teste 1: Cálculo do Escore de Risco ---
    test('calculateAnalytics deve retornar um BehavioralAnalyticsModel válido', () async {
      final model = await analyticsService.calculateAnalytics();

      // Verifica o tipo de retorno
      expect(model, isA<BehavioralAnalyticsModel>());
      
      // Verifica se os campos obrigatórios têm valores válidos (baseado na simulação)
      expect(model.loginFrequency, isNonNegative);
      expect(model.avgSessionDurationInMinutes, isNonNegative);
      expect(model.panicActivations, isNonNegative);
      
      // Verifica se o Escore de Risco está dentro do intervalo esperado (0.0 a 1.0)
      expect(model.riskScore, greaterThanOrEqualTo(0.0));
      expect(model.riskScore, lessThanOrEqualTo(1.0));
    });

    // --- Teste 2: Rastreamento de Evento (trackEvent) ---
    test('trackEvent deve executar sem lançar exceções', () async {
      // O método trackEvent é uma simulação (debug print e adição à lista local)
      // O teste garante que ele pode ser chamado com segurança pelo Notifier.
      
      expect(
        () async => await analyticsService.trackEvent('login'), 
        returnsNormally,
      );
      
      expect(
        () async => await analyticsService.trackEvent('panic_button'), 
        returnsNormally,
      );
    });

    // --- Teste 3: Consistência do Escore de Risco (Lógica Simulada) ---
    // Este teste depende da lógica interna da simulação (que é aleatória),
    // mas em um cenário real, testaríamos a fórmula exata com Mocks.
    test('calculateAnalytics retorna um Escore de Risco', () async {
      final model = await analyticsService.calculateAnalytics();
      // Apenas confirma que o score foi calculado
      expect(model.riskScore, isNotNull);
    });
  });
}