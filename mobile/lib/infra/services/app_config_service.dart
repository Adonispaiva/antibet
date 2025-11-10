import 'dart:convert';
import 'package:flutter/foundation.dart';

// Importação do modelo de Domínio
import '../../core/domain/app_config_model.dart';

/// SIMULAÇÃO DE PERSISTÊNCIA LOCAL
/// No projeto real, esta classe usaria um package como SharedPreferences ou Hive
class _LocalConfigStorage {
  // Simulação de armazenamento in-memory (Map)
  static final Map<String, String> _storage = {};

  Future<String?> read(String key) async {
    await Future.delayed(const Duration(milliseconds: 10)); // Simula async I/O
    return _storage[key];
  }

  Future<void> write(String key, String value) async {
    await Future.delayed(const Duration(milliseconds: 10));
    _storage[key] = value;
  }
  
  // Método auxiliar para testes e garantia de isolamento
  static void clear() => _storage.clear();
}

/// O serviço de Configurações é responsável pela persistência local
/// da entidade AppConfigModel.
class AppConfigService {
  final _LocalConfigStorage _localConfigStorage;
  static const String _storageKey = 'appConfigData';

  // O construtor é ajustado para facilitar a injeção em testes
  AppConfigService({_LocalConfigStorage? localConfigStorage}) 
      : _localConfigStorage = localConfigStorage ?? _LocalConfigStorage();

  /// Carrega as configurações salvas no dispositivo.
  Future<AppConfigModel> loadConfig() async {
    try {
      final jsonString = await _localConfigStorage.read(_storageKey);
      
      if (jsonString != null) {
        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        return AppConfigModel.fromJson(jsonMap);
      }
      
      // Se não houver configuração salva, retorna o padrão
      return kDefaultAppConfig;
      
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar configurações: $e');
      }
      // Em caso de erro de deserialização ou I/O, retorna o padrão
      return kDefaultAppConfig;
    }
  }

  /// Salva as configurações atualizadas no dispositivo.
  Future<void> saveConfig(AppConfigModel config) async {
    try {
      final jsonString = json.encode(config.toJson());
      await _localConfigStorage.write(_storageKey, jsonString);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao salvar configurações: $e');
      }
      // O erro é silencioso, pois o app deve continuar funcionando
    }
  }
}