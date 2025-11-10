import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:antibet/src/core/services/behavioral_analytics_service.dart';
import 'package:antibet/src/core/services/lockdown_service.dart';

// Mocks
// Mock do LockdownService que é uma dependência do BehavioralAnalyticsService
class MockLockdownService extends Mock implements LockdownService {
  @override
  Future<void> activateLockdown() => super.noSuchMethod(
        Invocation.method(#activateLockdown, []),
        returnValue: Future.value(null),
      ) as Future<void>;
}

void main() {
  late MockLockdownService mockLockdownService;
  late BehavioralAnalyticsService service;

  setUp(() {
    mockLockdownService = MockLockdownService();
    // Inicializa o serviço com o mock
    service = BehavioralAnalyticsService(lockdownService: mockLockdownService);
  });

  group('BehavioralAnalyticsService Tests', () {
    test('Initial risk score should be 0.0', () {
      expect(service.riskScore, equals(0.0));
      expect(service.isHighRisk, isFalse);
    });

    test('Risk score is clamped between 0.0 and 1.0 after calculation', () async {
      await service.calculateRiskScore();
      
      // O cálculo simulado no serviço varia, mas deve estar entre 0.0 e 1.0.
      expect(service.riskScore, greaterThanOrEqualTo(0.0));
      expect(service.riskScore, lessThanOrEqualTo(1.0));
    });

    test('isHighRisk should be true when riskScore >= HIGH_RISK_THRESHOLD (0.70)', () async {
      // Manipula o score diretamente (simulando um cálculo que resulta em 0.75)
      await service.calculateRiskScore(); // Executa o cálculo randômico primeiro

      // Sobrescreve a variável privada do score (simulação ideal para teste de limite)
      // Nota: Em Dart real, você usaria um setter ou Injeção de Dependência mais complexa
      // ou testaria exaustivamente o cálculo randômico até atingir o limite.
      // Aqui, vamos simular que o cálculo ocorreu e atingiu o limite:
      (service as dynamic)._currentRiskScore = 0.70; 
      
      expect(service.riskScore, equals(0.70));
      expect(service.isHighRisk, isTrue);

      (service as dynamic)._currentRiskScore = 0.71;
      expect(service.isHighRisk, isTrue);
    });

    test('isHighRisk should be false when riskScore < HIGH_RISK_THRESHOLD (0.70)', () async {
      // Simula que o cálculo resultou em 0.69
      (service as dynamic)._currentRiskScore = 0.69; 
      
      expect(service.isHighRisk, isFalse);
    });

    test('recordBehavioralEvent should increase risk score', () async {
      // Configura o score inicial baixo
      (service as dynamic)._currentRiskScore = 0.50; 
      
      // Evento que simula aumento de risco de 0.1
      await service.recordBehavioralEvent('tentativa_de_aposta');
      
      // O score deve ter aumentado para 0.60
      expect(service.riskScore, equals(0.60));
      
      // Outro evento que simula aumento de risco (score 0.70)
      await service.recordBehavioralEvent('consulta_sites_aposta');
      expect(service.riskScore, equals(0.70));
      expect(service.isHighRisk, isTrue);
    });

    test('recordPanicIntervention should be called without error', () {
      // A função apenas loga no Service, mas garante que não há erros de execução
      expect(() => service.recordPanicIntervention(), returnsNormally);
      // Se houvesse interação direta com o LockdownService, o mock seria verificado aqui.
    });
  });
}