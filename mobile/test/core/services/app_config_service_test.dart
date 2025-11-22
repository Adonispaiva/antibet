import 'package:antibet/core/services/app_config_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock da classe SharedPreferences para simular o armazenamento persistente
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  MockSharedPreferences mockSharedPreferences;
  AppConfigService appConfigService;

  // Define chaves de teste
  const String testKeyDarkMode = 'darkMode';
  const String testKeyCurrency = 'currency';
  const String defaultCurrency = 'BRL';

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    appConfigService = AppConfigService(mockSharedPreferences);
  });

  group('AppConfigService Unit Tests', () {
    test('should save dark mode preference correctly', () async {
      const bool isDarkMode = true;
      // Configura o mock para que setBool retorne true (sucesso na escrita)
      when(mockSharedPreferences.setBool(testKeyDarkMode, isDarkMode)).thenAnswer((_) async => true);

      final result = await appConfigService.setDarkMode(isDarkMode);

      // Verifica se o método setBool foi chamado com os argumentos corretos
      verify(mockSharedPreferences.setBool(testKeyDarkMode, isDarkMode)).called(1);
      // Verifica se o serviço reportou sucesso
      expect(result, isTrue);
    });

    test('should load dark mode preference correctly', () async {
      const bool savedDarkMode = false;
      // Configura o mock para que getBool retorne o valor simulado
      when(mockSharedPreferences.getBool(testKeyDarkMode)).thenReturn(savedDarkMode);

      final result = await appConfigService.getDarkMode();

      // Verifica se o método getBool foi chamado
      verify(mockSharedPreferences.getBool(testKeyDarkMode)).called(1);
      // Verifica se o serviço retornou o valor esperado
      expect(result, equals(savedDarkMode));
    });

    test('should return false if dark mode preference is not set (null)', () async {
      // Configura o mock para que getBool retorne null (nenhuma preferência salva)
      when(mockSharedPreferences.getBool(testKeyDarkMode)).thenReturn(null);

      final result = await appConfigService.getDarkMode();

      // O serviço deve tratar o null e retornar o padrão (false)
      expect(result, isFalse);
    });

    test('should save and load currency preference correctly', () async {
      const String selectedCurrency = 'USD';
      
      // Save test
      when(mockSharedPreferences.setString(testKeyCurrency, selectedCurrency)).thenAnswer((_) async => true);
      await appConfigService.setCurrency(selectedCurrency);
      verify(mockSharedPreferences.setString(testKeyCurrency, selectedCurrency)).called(1);

      // Load test
      when(mockSharedPreferences.getString(testKeyCurrency)).thenReturn(selectedCurrency);
      final loadedCurrency = await appConfigService.getCurrency();
      verify(mockSharedPreferences.getString(testKeyCurrency)).called(1);
      
      expect(loadedCurrency, equals(selectedCurrency));
    });

    test('should return default currency if currency preference is not set (null)', () async {
      // Configura o mock para retornar null
      when(mockSharedPreferences.getString(testKeyCurrency)).thenReturn(null);

      final loadedCurrency = await appConfigService.getCurrency();

      // O serviço deve retornar o valor padrão definido ('BRL')
      expect(loadedCurrency, equals(defaultCurrency));
    });
  });
}