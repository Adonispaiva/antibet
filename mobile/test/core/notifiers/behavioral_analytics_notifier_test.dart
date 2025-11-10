import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:antibet/src/core/services/behavioral_analytics_service.dart';
import 'package:antibet/src/core/notifiers/behavioral_analytics_notifier.dart';

// Mocks
class MockBehavioralAnalyticsService extends Mock implements BehavioralAnalyticsService {
  @override
  Future<double> calculateRiskScore() => super.noSuchMethod(
        Invocation.method(#calculateRiskScore, []),
        returnValue: Future.value(0.5), // Valor padrão para mock
      ) as Future<double>;

  @override
  bool get isHighRisk => super.noSuchMethod(
        Invocation.getter(#isHighRisk),
        returnValue: false,
      ) as bool;

  @override
  Future<void> recordBehavioralEvent(String eventType, [Map<String, dynamic>? details]) => super.noSuchMethod(
        Invocation.method(#recordBehavioralEvent, [eventType, details]),
        returnValue: Future.value(null),
      ) as Future<void>;
  
  @override
  void recordPanicIntervention() => super.noSuchMethod(
        Invocation.method(#recordPanicIntervention, []),
        returnValue: null,
      );
}

void main() {
  late MockBehavioralAnalyticsService mockService;
  late BehavioralAnalyticsNotifier notifier;

  setUp(() {
    mockService = MockBehavioralAnalyticsService();
    
    // Configura o mock inicial para retornar um score seguro na inicialização
    when(mockService.calculateRiskScore()).thenAnswer((_) => Future.value(0.3));
    when(mockService.isHighRisk).thenReturn(false);

    // Inicializa o notifier. O construtor chama calculateAnalytics().
    notifier = BehavioralAnalyticsNotifier(service: mockService);
  });

  group('BehavioralAnalyticsNotifier - Initialization and State', () {
    test('Should check initial status upon creation and set score', () async {
      // O construtor chama o cálculo, então o service deve ser chamado uma vez.
      verify(mockService.calculateRiskScore()).called(1);
      
      // Espera um microtask para garantir que o Future do construtor complete.
      await Future.microtask(() {}); 
      
      // O estado deve refletir o valor mockado (0.3)
      expect(notifier.riskScore, equals(0.3));
      expect(notifier.isHighRisk, isFalse);
    });
  });

  group('BehavioralAnalyticsNotifier - Recalculation and Events', () {
    test('calculateAnalytics should update state and notify listeners', () async {
      // Configura o mock para um novo score e risco alto
      when(mockService.calculateRiskScore()).thenAnswer((_) => Future.value(0.8));
      when(mockService.isHighRisk).thenReturn(true);
      
      final listener = MockListener();
      notifier.addListener(listener);

      // Simula o recálculo
      await notifier.calculateAnalytics();

      // Verifica o novo estado
      expect(notifier.riskScore, equals(0.8));
      expect(notifier.isHighRisk, isTrue);

      // O listener deve ser notificado
      verify(listener()).called(1);
      
      notifier.removeListener(listener);
    });

    test('recordBehavioralEvent should call service and force recalculation', () async {
      // Configura um mock para o evento no service e outro para o score no recalculo
      when(mockService.calculateRiskScore()).thenAnswer((_) => Future.value(0.6)); // Novo score
      
      final listener = MockListener();
      notifier.addListener(listener);

      // Simula o registro de um evento
      await notifier.recordBehavioralEvent('tentativa_de_aposta', {'value': 100});

      // 1. Verifica se o evento foi registrado no Service
      verify(mockService.recordBehavioralEvent('tentativa_de_aposta', {'value': 100})).called(1);

      // 2. Verifica se o calculateAnalytics foi chamado novamente para atualizar o score
      verify(mockService.calculateRiskScore()).called(2); // 1 na inicialização + 1 agora

      // 3. O estado deve atualizar e notificar
      expect(notifier.riskScore, equals(0.6));
      verify(listener()).called(1);
      
      notifier.removeListener(listener);
    });

    test('recordPanicIntervention should call service and recalculate', () async {
      when(mockService.calculateRiskScore()).thenAnswer((_) => Future.value(0.1)); // Score baixo após pânico
      
      final listener = MockListener();
      notifier.addListener(listener);

      notifier.recordPanicIntervention();
      
      // Verifica se o service foi notificado
      verify(mockService.recordPanicIntervention()).called(1);
      
      // Verifica se o recálculo foi chamado (o notifyListeners virá daqui)
      verify(mockService.calculateRiskScore()).called(2); 

      await Future.microtask(() {}); // Permite o Future do recalculate finalizar
      
      expect(notifier.riskScore, equals(0.1));
      verify(listener()).called(1);
      
      notifier.removeListener(listener);
    });
  });
}

// Helper para testar se notifyListeners foi chamado
class MockListener extends Mock {
  void call();
}