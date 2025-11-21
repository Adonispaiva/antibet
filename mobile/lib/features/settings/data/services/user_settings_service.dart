import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antibet/core/local_storage/storage_service.dart';
import 'package:antibet/features/settings/data/models/user_settings_model.dart';

/// Chave de armazenamento para as configurações do usuário.
const String _SETTINGS_KEY = 'user_settings';

/// Serviço responsável por carregar e salvar as configurações do usuário no StorageService.
class UserSettingsService {
  final StorageService _storage;

  UserSettingsService(this._storage);

  /// Carrega as configurações do usuário do armazenamento local.
  /// Retorna o modelo padrão (initial) se nenhuma configuração for encontrada.
  UserSettingsModel loadSettings() {
    final jsonString = _storage.getString(_SETTINGS_KEY);
    
    if (jsonString != null) {
      try {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        return UserSettingsModel.fromJson(jsonMap);
      } catch (e) {
        // Em caso de falha na desserialização, retorna o padrão e loga o erro.
        // print('Falha ao carregar configurações: $e'); 
        return UserSettingsModel.initial();
      }
    }
    
    return UserSettingsModel.initial();
  }

  /// Salva as configurações do usuário no armazenamento local.
  Future<bool> saveSettings(UserSettingsModel settings) async {
    try {
      final jsonString = json.encode(settings.toJson());
      return await _storage.setString(_SETTINGS_KEY, jsonString);
    } catch (e) {
      // print('Falha ao salvar configurações: $e');
      return false;
    }
  }
}

/// Provider que fornece o UserSettingsService, dependendo do StorageService.
final userSettingsServiceProvider = Provider<UserSettingsService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return UserSettingsService(storage);
});