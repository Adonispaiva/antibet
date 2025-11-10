import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Importações dos componentes a serem testados e dependências
import 'package:antibet_mobile/core/domain/app_config_model.dart';
import 'package:antibet_mobile/infra/services/app_config_service.dart';
import 'package:antibet_mobile/notifiers/app_config_notifier.dart';

// Gera o mock para a dependência
@GenerateMocks([AppConfigService])
import 'app_config_notifier_test.mocks.dart'; 

void main() {
  late MockAppConfigService mockConfigService;
  late AppConfigNotifier appConfigNotifier;

  const AppConfigModel savedConfig = AppConfigModel(
    isDarkMode: true,
    areNotificationsEnabled: false,
    languageCode: 'en',
  );

  // Configuração executada antes de cada teste
  setUp(() {
    mockConfigService = MockAppConfigService();
    // Injeta o mock
    appConfigNotifier = AppConfigNotifier(mockConfigService); 
  });

  // Limpeza executada após cada teste
  tearDown(() {
    reset(mockConfigService);
  });

  group('AppConfigNotifier - Initialization and Loading', () {
    // --- Teste 1: Estado Inicial ---
    test('Estado inicial é loading=true e config é o padrão', () {
      expect(appConfigNotifier.isLoading, isTrue);
      expect(appConfigNotifier.config, kDefaultAppConfig);
    });

    // --- Teste 2: Carregamento Bem-Sucedido de Config Salva ---
    test('loadConfig carrega configurações salvas e muda estado para loaded', () async {
      // Configuração: Serviço retorna uma configuração customizada
      when(mockConfigService.loadConfig()).thenAnswer((_) async => savedConfig);
      
      // Ouve as notificações (initial/loading é true, depois false)
      final listener = MockAppConfigListener();
      appConfigNotifier.addListener(listener);

      await appConfigNotifier.loadConfig();

      // Verifica as transições de estado (loading=true -> loading=false)
      verify(listener.call()).called(2); 
      expect(appConfigNotifier.isLoading, isFalse);
      expect(appConfigNotifier.config, savedConfig);
      expect(appConfigNotifier.isDarkMode, isTrue);
      
      verify(mockConfigService.loadConfig()).called(1);
    });

    // --- Teste 3: Carregamento Mal-Sucedido (Fallback para Padrão) ---
    test('loadConfig trata erro e cai para o padrão, e muda estado para loaded', () async {
      // Configuração: Serviço lança erro
      when(mockConfigService.loadConfig()).thenThrow(Exception('Falha de I/O'));
      
      await appConfigNotifier.loadConfig();

      // Verifica o estado final
      expect(appConfigNotifier.isLoading, isFalse);
      // O service tem fallback interno para kDefaultAppConfig em caso de erro
      expect(appConfigNotifier.config, kDefaultAppConfig); 
      expect(appConfigNotifier.isDarkMode, isFalse); 
      
      verify(mockConfigService.loadConfig()).called(1);
    });
  });

  group('AppConfigNotifier - Update and Persistence', () {
    setUp(() async {
      // Garante que o Notifier esteja no estado loaded com config salva
      when(mockConfigService.loadConfig()).thenAnswer((_) async => savedConfig);
      await appConfigNotifier.loadConfig(); 
      reset(mockConfigService); // Limpa as interações de load
    });

    // --- Teste 4: Atualização de Dark Mode (Persistência) ---
    test('updateConfig atualiza o estado local e chama saveConfig', () async {
      when(mockConfigService.saveConfig(any)).thenAnswer((_) async {});
      
      await appConfigNotifier.updateConfig(isDarkMode: false); // Muda de true (salvo) para false

      // Verifica o estado local
      expect(appConfigNotifier.isDarkMode, isFalse); 
      
      // Verifica se o saveConfig foi chamado com a nova configuração
      verify(mockConfigService.saveConfig(
        argThat(
          isA<AppConfigModel>()
          .having((c) => c.isDarkMode, 'isDarkMode', isFalse)
          .having((c) => c.languageCode, 'languageCode', 'en') // Não deve mudar o resto
        )
      )).called(1);
    });

    // --- Teste 5: Atualização Múltipla (Imutabilidade) ---
    test('updateConfig atualiza múltiplos campos usando copyWith', () async {
      when(mockConfigService.saveConfig(any)).thenAnswer((_) async {});
      
      await appConfigNotifier.updateConfig(
        areNotificationsEnabled: true, // Muda de false para true
        languageCode: 'fr',
      );

      // Verifica o estado local
      expect(appConfigNotifier.areNotificationsEnabled, isTrue);
      expect(appConfigNotifier.languageCode, 'fr'); 
      expect(appConfigNotifier.isDarkMode, isTrue); // Permanece o valor original

      // Verifica se o saveConfig foi chamado
      verify(mockConfigService.saveConfig(any)).called(1);
    });

    // --- Teste 6: Evita I/O Desnecessário ---
    test('updateConfig não chama saveConfig se a config não mudar', () async {
      
      await appConfigNotifier.updateConfig(
        isDarkMode: true, // Já é true
        languageCode: 'en', // Já é 'en'
      );

      // Verifica que o saveConfig nunca foi chamado
      verifyNever(mockConfigService.saveConfig(any));
    });
  });
}

// Classe de mock simples para o Listener do ChangeNotifier
class MockAppConfigListener extends Mock {
  void call();
}