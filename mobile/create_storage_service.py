import os
import sys

# Define o caminho de destino no projeto
OUTPUT_PATH = "lib/core/services/storage_service.dart"

# Conteúdo completo do arquivo storage_service.dart como string literal
STORAGE_SERVICE_CONTENT = """
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Este serviço atua como a camada de infraestrutura de persistência de chave/valor
// para todos os outros services (Auth, Journal, Strategy, etc.).
class StorageService {
  final SharedPreferences sharedPreferences;

  StorageService({required this.sharedPreferences});

  /// Salva uma lista de objetos serializáveis sob uma chave.
  Future<bool> saveList<T>(String key, List<T> items, Map<String, dynamic> Function(T) toJson) async {
    try {
      final jsonList = items.map((item) => toJson(item)).toList();
      final stringList = jsonList.map((json) => jsonEncode(json)).toList();
      return await sharedPreferences.setStringList(key, stringList);
    } catch (e) {
      // Logar erro
      return false;
    }
  }

  /// Carrega uma lista de objetos e desserializa.
  List<T> loadList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    try {
      final stringList = sharedPreferences.getStringList(key) ?? [];
      return stringList.map((jsonString) {
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
        return fromJson(jsonMap);
      }).toList();
    } catch (e) {
      // Logar erro e retornar lista vazia
      return [];
    }
  }

  /// Salva um único objeto serializável.
  Future<bool> saveObject<T>(String key, T item, Map<String, dynamic> Function(T) toJson) async {
    try {
      final jsonMap = toJson(item);
      final jsonString = jsonEncode(jsonMap);
      return await sharedPreferences.setString(key, jsonString);
    } catch (e) {
      // Logar erro
      return false;
    }
  }

  /// Carrega um único objeto e desserializa.
  T? loadObject<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    try {
      final jsonString = sharedPreferences.getString(key);
      if (jsonString == null) return null;
      
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(jsonMap);
    } catch (e) {
      // Logar erro
      return null;
    }
  }

  /// Limpa um item específico.
  Future<bool> remove(String key) async {
    return await sharedPreferences.remove(key);
  }

  /// Limpa todas as chaves do aplicativo (útil para Logout).
  Future<bool> clearAll() async {
    return await sharedPreferences.clear();
  }
}
"""

def create_file():
    full_path = os.path.join(os.getcwd(), OUTPUT_PATH)
    directory = os.path.dirname(full_path)

    if not os.path.exists(directory):
        os.makedirs(directory, exist_ok=True)
    
    try:
        with open(full_path, 'w', encoding='utf-8') as outfile:
            outfile.write(STORAGE_SERVICE_CONTENT.strip())
        print(f"\n✅ Successfully deployed: {OUTPUT_PATH}")
        print("✅ Storage Service implantado com sucesso.")
    except Exception as e:
        print(f"\n❌ ERRO FATAL: Falha ao escrever o arquivo. {e}")
        sys.exit(1)

if __name__ == '__main__':
    create_file()