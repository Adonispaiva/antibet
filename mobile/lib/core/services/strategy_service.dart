import 'dart:convert';
import 'package:antibet/core/models/strategy_model.dart';
import 'package:antibet/core/services/storage_service.dart';

/// Serviço responsável por gerenciar a lógica de negócios e a persistência
/// das Estratégias de Trading do usuário.
/// Esta é a implementação real (Fase 3).
class StrategyService {
  final StorageService _storageService;

  // Chave única para salvar a lista de estratégias.
  static const String _storageKey = 'user_strategies';

  StrategyService({required StorageService storageService})
      : _storageService = storageService;

  /// Carrega a lista de estratégias do armazenamento local.
  Future<List<StrategyModel>> loadStrategies() async {
    try {
      // 1. Lê a string JSON bruta do StorageService
      final String? jsonString = await _storageService.readData(_storageKey);

      if (jsonString != null) {
        // 2. Decodifica a string em uma Lista de mapas dinâmicos
        final List<dynamic> decodedList = json.decode(jsonString) as List;

        // 3. Mapeia a lista dinâmica para uma lista de StrategyModel
        final List<StrategyModel> strategies = decodedList
            .map((item) => StrategyModel.fromJson(item as Map<String, dynamic>))
            .toList();
            
        return strategies;
      }
      // Se não houver dados salvos, retorna uma lista vazia
      return [];
    } catch (e) {
      print('Erro ao carregar StrategyService: $e');
      return []; // Retorna lista vazia em caso de erro
    }
  }

  /// Salva a lista completa de estratégias no armazenamento local.
  Future<void> saveStrategies(List<StrategyModel> strategies) async {
    try {
      // 1. Mapeia a lista de Modelos para uma lista de Maps (JSON)
      final List<Map<String, dynamic>> jsonList =
          strategies.map((strategy) => strategy.toJson()).toList();

      // 2. Codifica a lista de Mapas em uma string JSON
      final String jsonString = json.encode(jsonList);

      // 3. Salva a string JSON no StorageService
      await _storageService.saveData(_storageKey, jsonString);
    } catch (e) {
      print('Erro ao salvar StrategyService: $e');
      // Tratar erro
    }
  }
}