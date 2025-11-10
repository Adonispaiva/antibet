import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Importações dos componentes a serem testados e dependências
import 'package:antibet_mobile/core/domain/help_and_alerts_model.dart';
import 'package:antibet_mobile/infra/services/help_and_alerts_service.dart';
import 'package:antibet_mobile/notifiers/help_and_alerts_notifier.dart';

// Gera o mock para a dependência
@GenerateMocks([HelpAndAlertsService])
import 'help_and_alerts_notifier_test.mocks.dart'; 

void main() {
  late MockHelpAndAlertsService mockAlertsService;
  late HelpAndAlertsNotifier alertsNotifier;

  const HelpResourceModel mockResource = HelpResourceModel(
    title: 'Jogadores Anônimos',
    url: 'https://jogadoresanonimos.org.br',
    type: 'website',
  );
  final HelpAndAlertsModel mockModel = HelpAndAlertsModel(
    supportResources: [mockResource],
    lastTriggeredAlert: null,
  );
  const AlertsServiceException serviceError = AlertsServiceException('Falha de conexão.');

  // Configuração executada antes de cada teste
  setUp(() {
    mockAlertsService = MockHelpAndAlertsService();
    // Injeta o mock
    alertsNotifier = HelpAndAlertsNotifier(mockAlertsService); 
  });

  // Limpeza executada após cada teste
  tearDown(() {
    reset(mockAlertsService);
  });

  group('HelpAndAlertsNotifier - Fetch Resources', () {
    // --- Teste 1: Estado Inicial ---
    test('Estado inicial é HelpState.initial e lista de recursos está vazia', () {
      expect(alertsNotifier.state, HelpState.initial);
      expect(alertsNotifier.resources, isEmpty);
    });

    // --- Teste 2: Busca Bem-Sucedida ---
    test('fetchResources: sucesso carrega recursos e muda para HelpState.loaded', () async {
      // Configuração: Serviço retorna o modelo
      when(mockAlertsService.fetchResources()).thenAnswer((_) async => mockModel);
      
      await alertsNotifier.fetchResources();

      // Verifica as transições de estado
      expect(alertsNotifier.state, HelpState.loaded);
      expect(alertsNotifier.resources, hasLength(1));
      expect(alertsNotifier.resources.first.title, 'Jogadores Anônimos');
      
      verify(mockAlertsService.fetchResources()).called(1);
    });

    // --- Teste 3: Busca Mal-Sucedida ---
    test('fetchResources: falha define erro e muda para HelpState.error', () async {
      // Configuração: Serviço lança exceção
      when(mockAlertsService.fetchResources()).thenThrow(serviceError);
      
      await alertsNotifier.fetchResources();

      // Verifica o estado final
      expect(alertsNotifier.state, HelpState.error);
      expect(alertsNotifier.resources, isEmpty);
      expect(alertsNotifier.errorMessage, contains('Falha ao carregar recursos de ajuda'));
      
      verify(mockAlertsService.fetchResources()).called(1);
    });
  });

  group('HelpAndAlertsNotifier - Trigger Alert', () {
    // Prepara o notifier com dados carregados
    setUp(() async {
      when(mockAlertsService.fetchResources()).thenAnswer((_) async => mockModel);
      await alertsNotifier.fetchResources(); 
      reset(mockAlertsService); // Limpa interações de fetch
    });
    
    const String alertReason = 'Tentativa de desativar regras de controle.';

    // --- Teste 4: Acionamento de Alerta ---
    test('triggerAlert deve chamar o serviço e atualizar o estado local', () async {
      // Configuração: Serviço de alerta não retorna erro
      when(mockAlertsService.triggerAlert(alertReason)).thenAnswer((_) async {});
      
      await alertsNotifier.triggerAlert(alertReason);

      // Verifica o estado local (atualização imediata)
      expect(alertsNotifier.model?.lastTriggeredAlert, alertReason);
      expect(alertsNotifier.model?.lastAlertTimestamp, isNotNull);
      
      // Verifica se o serviço foi chamado
      verify(mockAlertsService.triggerAlert(alertReason)).called(1);
    });

    // --- Teste 5: Falha no Acionamento de Alerta (Silencioso) ---
    test('triggerAlert deve atualizar estado local mesmo se o serviço falhar', () async {
      // Configuração: Serviço de alerta lança erro
      when(mockAlertsService.triggerAlert(alertReason)).thenThrow(serviceError);
      
      await alertsNotifier.triggerAlert(alertReason);
      
      // O estado local deve ser atualizado (feedback imediato da UI)
      expect(alertsNotifier.model?.lastTriggeredAlert, alertReason);
      
      // A falha do serviço é logada, mas o Notifier não entra em estado de erro
      expect(alertsNotifier.state, HelpState.loaded);
      verify(mockAlertsService.triggerAlert(alertReason)).called(1);
    });
  });
}