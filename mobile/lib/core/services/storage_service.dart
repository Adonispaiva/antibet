import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Para codificar/decodificar JSON

/// Serviço de baixo nível responsável pela persistência de dados no
/// armazenamento local do dispositivo (usando SharedPreferences).
/// Esta é a implementação real (Fase 3), substituindo a simulação.
class StorageService {
  // Instância estática do SharedPreferences.
  static SharedPreferences? _prefs;

  /// Inicializa o serviço de armazenamento.
  /// Deve ser chamado no 'main.dart' ANTES de DependencyInjection.initialize().
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Salva dados (String) no armazenamento local usando uma chave.
  Future<void> saveData(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  /// Lê dados (String) do armazenamento local usando uma chave.
  Future<String?> readData(String key) async {
    return _prefs?.getString(key);
  }

  /// Remove dados do armazenamento local usando uma chave.
  Future<void> deleteData(String key) async {
    await _prefs?.remove(key);
  }

  /// Salva um objeto complexo (Map/List) como JSON.
  Future<void> saveJson(String key, Map<String, dynamic> data) async {
    try {
      String jsonString = json.encode(data);
      await saveData(key, jsonString);
    } catch (e) {
      // Lidar com erro de codificação
      print('Erro ao salvar JSON no StorageService: $e');
    }
  }

  /// Lê um objeto complexo (Map/List) salvo como JSON.
  Future<Map<String, dynamic>?> readJson(String key) async {
    try {
      String? jsonString = await readData(key);
      if (jsonString != null) {
        return json.decode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      // Lidar com erro de decodificação
      print('Erro ao ler JSON no StorageService: $e');
      return null;
    }
  }
}