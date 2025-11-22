import 'package:antibet/core/notifiers/app_config_notifier.dart';
import 'package:antibet/core/services/app_config_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Mock da classe AppConfigService, que é a dependência do Notifier
class MockAppConfigService extends Mock implements AppConfigService {}

void main() {
  MockAppConfigService mockAppConfigService;
  AppConfigNotifier appConfigNotifier;

  setUp(() {
    mockAppConfigService = MockAppConfigService();
    // Inicializa o Notifier com o Service mockado
    appConfigNotifier = AppConfigNotifier(mockAppConfigService);
  });

  group('AppConfigNotifier Unit Tests', () {
    test('initial state should reflect loaded configuration (Dark Mode: false)', () async {
      // 1. Configura o mock para simular que o modo escuro NÃO está ativo no storage.
      when(mockAppConfigService.getDarkMode()).thenAnswer((_) async => false);
      when(mockAppConfigService.getCurrency()).thenAnswer((_) async => 'BRL');
      
      // 2. Chama o método de carregamento inicial
      await appConfigNotifier.loadInitialConfig();

      // 3. Verificação
      expect(appConfigNotifier.isDarkMode, isFalse);
      expect(appConfigNotifier.currency, equals('BRL'));
      verify(mockAppConfigService.getDarkMode()).called(1);
    });

    test('initial state should reflect loaded configuration (Dark Mode: true)', () async {
      // 1. Configura o mock para simular que o modo escuro ESTÁ ativo no storage.
      when(mockAppConfigService.getDarkMode()).thenAnswer((_) async => true);
      when(mockAppConfigService.getCurrency()).thenAnswer((_) async => 'USD');

      // 2. Chama o método de carregamento inicial
      await appConfigNotifier.loadInitialConfig();

      // 3. Verificação
      expect(appConfigNotifier.isDarkMode, isTrue);
      expect(appConfigNotifier.currency, equals('USD'));
    });
    
    test('setDarkMode should update state, call service, and notify listeners', () async {
      const bool newMode = true;
      
      // 1. Configura o mock para que a escrita no storage retorne sucesso
      when(mockAppConfigService.setDarkMode(newMode)).thenAnswer((_) async => true);
      
      // Monitora se o notifyListeners é chamado
      final listener = MockFunction();
      appConfigNotifier.addListener(listener.call);

      // 2. Chama o método de alteração
      await appConfigNotifier.setDarkMode(newMode);

      // 3. Verificação
      // Estado interno atualizado
      expect(appConfigNotifier.isDarkMode, isTrue);
      
      // Service chamado
      verify(mockAppConfigService.setDarkMode(newMode)).called(1);
      
      // Ouvintes notificados
      verify(listener()).called(1);
      
      appConfigNotifier.removeListener(listener.call);
    });

    test('setCurrency should update state, call service, and notify listeners', () async {
      const String newCurrency = 'EUR';
      
      // 1. Configura o mock
      when(mockAppConfigService.setCurrency(newCurrency)).thenAnswer((_) async => true);
      
      final listener = MockFunction();
      appConfigNotifier.addListener(listener.call);

      // 2. Chama o método de alteração
      await appConfigNotifier.setCurrency(newCurrency);

      // 3. Verificação
      expect(appConfigNotifier.currency, equals('EUR'));
      verify(mockAppConfigService.setCurrency(newCurrency)).called(1);
      verify(listener()).called(1);
      
      appConfigNotifier.removeListener(listener.call);
    });
  });
}

// Classe Mock auxiliar para rastrear chamadas a notifyListeners
class MockFunction extends Mock {
  call();
}