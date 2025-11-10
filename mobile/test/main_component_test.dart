import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

// Importa os arquivos principais
import 'package:antibet_app/main.dart'; 
import 'package:antibet_app/notifiers/auth_notifier.dart';
import 'package:antibet_app/notifiers/advertorial_detector_notifier.dart';
// Adicionar aqui todos os outros notifiers/services para mock
import 'package:antibet_app/infra/services/storage_service.dart';
import 'package:antibet_app/infra/services/auth_service.dart';
import 'package:antibet_app/infra/services/user_profile_service.dart';
import 'package:antibet_app/infra/services/app_config_service.dart';
import 'package:antibet_app/infra/services/dashboard_service.dart'; 
import 'package:antibet_app/infra/services/bet_strategy_service.dart';
import 'package:antibet_app/infra/services/help_and_alerts_service.dart';
import 'package:antibet_app/infra/services/lockdown_service.dart';
import 'package:antibet_app/infra/services/behavioral_analytics_service.dart'; 
import 'package:antibet_app/infra/services/advertorial_detector_service.dart';


// NOTA: É necessário gerar mocks para todos os Services/Notifiers que são
// utilizados no main.dart para evitar a inicialização real e testar apenas a DI.
@GenerateMocks([
  StorageService, AuthService, UserProfileService, AppConfigService,
  DashboardService, BetStrategyService, HelpAndAlertsService, 
  LockdownService, BehavioralAnalyticsService, AdvertorialDetectorService,
  http.Client,
])
import 'main_component_test.mocks.dart'; 

// Cria o mock para a função main (para injetar os mocks)
void main() {
  late MockStorageService mockStorageService;
  late MockAuthService mockAuthService;
  late MockAppConfigService mockAppConfigService;
  late MockLockdownService mockLockdownService;
  late MockAdvertorialDetectorService mockDetectorService;
  late MockClient mockHttpClient;

  setUp(() {
    // Inicialização dos Mocks
    mockStorageService = MockStorageService();
    mockAuthService = MockAuthService();
    mockAppConfigService = MockAppConfigService();
    mockLockdownService = MockLockdownService();
    mockDetectorService = MockAdvertorialDetectorService();
    mockHttpClient = MockClient();

    // Comportamento Mockado Essencial: 
    // Mocks devem retornar um Future.value([]) ou valor vazio para simular inicialização rápida.
    when(mockAuthService.checkStatus()).thenAnswer((_) async => true);
    when(mockAppConfigService.load()).thenAnswer((_) async => {});
    when(mockLockdownService.getStatus()).thenAnswer((_) async => false);
    
    // Configura o DetectorService Mock para injetar o HttpClient Mock
    when(mockDetectorService.httpClient).thenReturn(mockHttpClient);
    // Para evitar chamadas reais durante o teste
    when(mockDetectorService.baseUrl).thenReturn('http://test.url');
  });

  // Função helper que simula a inicialização do main com os mocks
  Widget createTestableWidget() {
    // Recria os notifiers/services com os mocks para isolamento
    final authService = MockAuthService();
    final detectorService = AdvertorialDetectorService(baseUrl: 'http://mock.url', httpClient: MockClient());
    
    // Usamos os Notifiers reais, mas injetamos Services mockados (ou instâncias simples)
    final authNotifier = AuthNotifier(authService);
    final detectorNotifier = AdvertorialDetectorNotifier(detectorService: detectorService);

    // Simplificamos a injeção para os notifiers essenciais para o teste de componentes
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthNotifier>.value(value: authNotifier),
        ChangeNotifierProvider<AdvertorialDetectorNotifier>.value(value: detectorNotifier),
        // Adicione aqui todos os outros notifiers e services com seus mocks
        // ... (Para testes completos, todos os 9 Notifiers e Services devem ser mockados/injetados)
      ],
      // O AppRouter deve ser mockado ou simplificado para este teste
      child: AntiBetMobileApp(appRouter: MockAppRouter(authNotifier, MockLockdownNotifier())), 
    );
  }

  group('Main Component Test - Q.R. de Arquitetura', () {
    testWidgets('Deve inicializar e injetar o AdvertorialDetectorNotifier', (WidgetTester tester) async {
      
      // 1. Arrange & Act (Monta o Widget no TestBench)
      await tester.pumpWidget(createTestableWidget());
      
      // 2. Assert: Verifica se a injeção do Provider foi bem-sucedida
      // Tentamos obter a instância do Provider no contexto da aplicação
      final detectorNotifier = tester.widget<ChangeNotifierProvider<AdvertorialDetectorNotifier>>(
        find.byType(ChangeNotifierProvider<AdvertorialDetectorNotifier>),
      ).value;

      // Verifica se o Provider foi injetado (não é nulo)
      expect(detectorNotifier, isNotNull);
      // Verifica o tipo de serviço injetado (deve ser o mock, mas aqui verificamos o tipo real)
      expect(detectorNotifier.detectorService, isA<AdvertorialDetectorService>());
      
      // Verifica a injeção de outro Provider essencial (para garantir a integridade do MultiProvider)
      final authNotifier = tester.widget<ChangeNotifierProvider<AuthNotifier>>(
        find.byType(ChangeNotifierProvider<AuthNotifier>),
      ).value;
      expect(authNotifier, isNotNull);
    });

    // Teste de Tema (Opcional, se o tema for um ponto de falha comum)
    testWidgets('Deve usar o MaterialApp.router (go_router) e o tema padrão', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      
      // Verifica se o MaterialApp.router foi usado
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Verifica se a tela inicial (BrowserScreen, que está por trás do Router) foi atingida
      // (Esta verificação é complexa devido ao AppRouter, mas verificamos o título como proxy)
      expect(find.text('AntiBet Mobile'), findsOneWidget); 
    });
  });
}