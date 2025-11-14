import 'package:antibet/core/services/storage_service.dart';
// import 'package:antibet/core/models/app_config_model.dart'; // Será usado quando o modelo for criado

/// Serviço responsável por gerenciar a persistência das configurações
/// do aplicativo (Ex: Tema, Notificações).
/// Esta é a implementação real (Fase 3).
class ConfigService {
  final StorageService _storageService;
  
  // Chave única para salvar as configurações no StorageService.
  static const String _storageKey = 'app_config';

  ConfigService({required StorageService storageService}) 
      : _storageService = storageService;

  /// Salva as configurações do aplicativo no armazenamento local.
  /// (Por enquanto, salva um Map simulando o AppConfigModel)
  Future<void> saveConfig({
    required bool isDarkMode,
    required bool areNotificationsEnabled,
  }) async {
    try {
      final configData = {
        'isDarkMode': isDarkMode,
        'areNotificationsEnabled': areNotificationsEnabled,
      };
      // Usa o método saveJson do StorageService
      await _storageService.saveJson(_storageKey, configData);
    } catch (e) {
      print('Erro ao salvar ConfigService: $e');
      // Tratar erro
    }
  }

  /// Carrega as configurações do aplicativo do armazenamento local.
  /// (Retorna um Map simulando o AppConfigModel)
  Future<Map<String, dynamic>?> loadConfig() async {
    try {
      // Usa o método readJson do StorageService
      final configData = await _storageService.readJson(_storageKey);
      
      if (configData != null) {
        // Retorna o Map (que será o AppConfigModel)
        return configData;
      }
      
      // Retorna nulo se não houver configurações salvas
      return null;
    } catch (e) {
      print('Erro ao carregar ConfigService: $e');
      // Tratar erro
      return null;
    }
  }
}