import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Importações dos componentes a serem testados e dependências
import 'package:antibet_mobile/core/domain/behavioral_analytics_model.dart';
import 'package:antibet_mobile/infra/services/behavioral_analytics_service.dart';
import 'package:antibet_mobile/notifiers/behavioral_analytics_notifier.dart';

// Gera o mock para a dependência
@GenerateMocks([BehavioralAnalyticsService])
import 'behavioral_analytics_notifier_test.mocks.dart'; 

void main() {
  late MockBehavioralAnalyticsService mockAnalyticsService;
  late BehavioralAnalyticsNotifier analyticsNotifier;

  final BehavioralAnalyticsModel mockAnalytics = BehavioralAnalyticsModel(
    loginFrequency: 4.0,
    avgSessionDurationInMinutes: 45.0,
    panicActivations: 1,
    riskScore: 1.0, // Risco Máximo (0.4 + 0.3 + 0.3)
  );

  // Configuração executada antes de cada teste
  setUp(() {
    mockAnalyticsService = MockBehavioralAnalyticsService();
    // Injeta o mock
    analyticsNotifier = BehavioralAnalyticsNotifier(mockAnalyticsService); 
  });

  // Limpeza executada após cada teste
  tearDown(() {
    reset(mockAnalyticsService);
  });

  group('BehavioralAnalyticsNotifier - Calculate Analytics (Escore de Risco)', () {
    // --- Teste 1: Estado Inicial ---
    test('Estado inicial é initial e Escore de Risco é 0.0', () {
      expect(analyticsNotifier.state, AnalyticsState.initial);
      expect(analyticsNotifier.riskScore, 0.0);
      expect(analyticsNotifier.model, BehavioralAnalyticsModel.defaultValues());
    });

    // --- Teste 2: Cálculo Bem-Sucedido ---
    test('calculateAnalytics: sucesso carrega modelo e muda estado para loaded', () async {
      // Configuração: Serviço retorna o modelo calculado
      when(mockAnalyticsService.calculateAnalytics()).thenAnswer((_) async => mockAnalytics);
      
      await analyticsNotifier.calculateAnalytics();

      // Verifica as transições de estado
      expect(analyticsNotifier.state, AnalyticsState.loaded);
      expect(analyticsNotifier.model, mockAnalytics);
      expect(analyticsNotifier.riskScore, 1.0);
      
      verify(mockAnalyticsService.calculateAnalytics()).called(1);
    });

    // --- Teste 3: Cálculo Mal-Sucedido (Falha de API) ---
    test('calculateAnalytics: falha define erro, muda estado para error e reseta o modelo', () async {
      // Configuração: Serviço lança exceção
      when(mockAnalyticsService.calculateAnalytics()).thenThrow(Exception('Falha de cálculo'));
      
      await analyticsNotifier.calculateAnalytics();

      // Verifica o estado final
      expect(analyticsNotifier.state, AnalyticsState.error);
      expect(analyticsNotifier.errorMessage, contains('Falha ao calcular o Escore de Risco'));
      
      // Garante que o modelo volte ao padrão seguro
      expect(analyticsNotifier.model, BehavioralAnalyticsModel.defaultValues());
      expect(analyticsNotifier.riskScore, 0.0);
      
      verify(mockAnalyticsService.calculateAnalytics()).called(1);
    });
  });

  group('BehavioralAnalyticsNotifier - Track Event (Rastreamento)', () {
    
    // --- Teste 4: Rastreamento (Fire-and-forget) ---
    test('trackEvent deve chamar o serviço sem mudar o estado da UI', () async {
      // Configuração: Serviço de rastreamento não retorna erro
      when(mockAnalyticsService.trackEvent(any)).thenAnswer((_) async {});
      
      // Estado inicial (Loaded, por exemplo)
      analyticsNotifier.state = AnalyticsState.loaded;

      await analyticsNotifier.trackEvent('login');

      // Verifica se o serviço foi chamado
      verify(mockAnalyticsService.trackEvent('login')).called(1);
      
      // O estado da UI não deve ser alterado (permanece loaded)
      expect(analyticsNotifier.state, AnalyticsState.loaded);
    });

    // --- Teste 5: Rastreamento com Falha (Silencioso) ---
    test('trackEvent deve ser silencioso e não mudar o estado da UI em caso de falha', () async {
      // Configuração: Serviço de rastreamento lança erro
      when(mockAnalyticsService.trackEvent(any)).thenThrow(Exception('Falha de I/O'));
      
      analyticsNotifier.state = AnalyticsState.loaded;

      await analyticsNotifier.trackEvent('panic_button');

      // Verifica se o serviço foi chamado
      verify(mockAnalyticsService.trackEvent('panic_button')).called(1);
      
      // O estado da UI não deve ser alterado (permanece loaded e sem erro)
      expect(analyticsNotifier.state, AnalyticsState.loaded);
      expect(analyticsNotifier.errorMessage, isNull);
    });
  });
}