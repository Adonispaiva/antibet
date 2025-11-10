import 'package:shared_preferences/shared_preferences.dart';

// O Serviço de Configuração gerencia preferências simples de UX.

class AppConfigService {
  // Chave de persistência para o modo escuro
  static const String _darkModeKey = 'app_dark_mode';

  // Armazena a referência às SharedPreferences
  late final SharedPreferences _prefs;

  // Construtor privado para inicialização assíncrona
  AppConfigService() {
    _initPrefs();
  }

  // Inicializa as SharedPreferences
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Carrega o status do modo escuro.
  Future<bool> loadDarkModeStatus() async {
    await _initPrefs();
    // Padrão: Modo Claro (false)
    return _prefs.getBool(_darkModeKey) ?? false;
  }

  /// Salva o novo status do modo escuro.
  Future<void> setDarkModeStatus(bool isDarkMode) async {
    await _initPrefs();
    await _prefs.setBool(_darkModeKey, isDarkMode);
    print('Modo Escuro alterado para: $isDarkMode');
  }
}