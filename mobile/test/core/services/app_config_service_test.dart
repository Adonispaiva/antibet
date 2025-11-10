import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:antibet/src/core/services/app_config_service.dart';

void main() {
  // Chave de persistência principal (duplicada para o teste)
  const String _darkModeKey = 'app_dark_mode';
  late AppConfigService service;

  setUp(() {
    // Limpa o mock de SharedPreferences antes de cada teste
    SharedPreferences.setMockInitialValues({});
    service = AppConfigService();
  });

  group('AppConfigService Tests', () {
    test('loadDarkModeStatus should return false (Light Mode) when no value is set', () async {
      final isDarkMode = await service.loadDarkModeStatus();
      
      // O valor padrão deve ser false (Modo Claro)
      expect(isDarkMode, isFalse);
    });

    test('setDarkModeStatus should persist the true value for dark mode', () async {
      const darkModeValue = true;
      
      await service.setDarkModeStatus(darkModeValue);
      
      final prefs = await SharedPreferences.getInstance();
      
      // Verifica se o valor booleano correto foi salvo
      expect(prefs.getBool(_darkModeKey), equals(darkModeValue));
    });

    test('loadDarkModeStatus should return the persisted true value', () async {
      // 1. Prepara o mock com o valor true
      SharedPreferences.setMockInitialValues({
        _darkModeKey: true,
      });
      
      // Recria o serviço para garantir que a inicialização use o mock
      service = AppConfigService(); 
      
      // 2. Carrega o status
      final isDarkMode = await service.loadDarkModeStatus();
      
      // Deve retornar o valor salvo
      expect(isDarkMode, isTrue);
    });
    
    test('setDarkModeStatus should persist the false value for light mode', () async {
      const darkModeValue = false;
      
      await service.setDarkModeStatus(darkModeValue);
      
      final prefs = await SharedPreferences.getInstance();
      
      // Verifica se o valor booleano correto foi salvo
      expect(prefs.getBool(_darkModeKey), equals(darkModeValue));
    });
  });
}