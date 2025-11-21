import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço para abstrair a leitura e escrita de dados persistentes no dispositivo.
class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  /// Obtém uma String do armazenamento local.
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Salva uma String no armazenamento local.
  Future<bool> setString(String key, String value) {
    return _prefs.setString(key, value);
  }

  /// Obtém um booleano do armazenamento local.
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// Salva um booleano no armazenamento local.
  Future<bool> setBool(String key, bool value) {
    return _prefs.setBool(key, value);
  }

  /// Remove uma chave específica.
  Future<bool> remove(String key) {
    return _prefs.remove(key);
  }

  /// Limpa todos os dados persistidos (ex: durante o logout completo).
  Future<bool> clear() {
    return _prefs.clear();
  }
}

/// Provider que fornece o StorageService (assíncrono, pois SharedPreferences.getInstance() é um Future).
/// A inicialização deve ser feita no main.dart.
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  // Inicialização assíncrona do SharedPreferences, necessária no main()
  return SharedPreferences.getInstance();
});

/// Provider que fornece o StorageService, dependendo da inicialização do SharedPreferences.
final storageServiceProvider = Provider<StorageService>((ref) {
  // Aguarda a inicialização do SharedPreferences
  final prefs = ref.watch(sharedPreferencesProvider); 
  
  return prefs.when(
    data: (prefsInstance) => StorageService(prefsInstance),
    loading: () => throw Exception("StorageService not initialized yet."),
    error: (err, stack) => throw Exception("Error initializing storage: $err"),
  );
});