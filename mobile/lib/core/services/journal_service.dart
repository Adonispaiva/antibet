import 'dart:convert';
import 'package:antibet/core/models/bet_journal_entry_model.dart';
import 'package:antibet/core/services/storage_service.dart';

/// Serviço responsável por gerenciar a lógica de negócios e a persistência
/// do Diário de Apostas (Bet Journal).
/// Esta é a implementação real (Fase 3).
class JournalService {
  final StorageService _storageService;

  // Chave única para salvar a lista de lançamentos do diário.
  static const String _storageKey = 'bet_journal';

  JournalService({required StorageService storageService})
      : _storageService = storageService;

  /// Carrega a lista de lançamentos do diário do armazenamento local.
  Future<List<BetJournalEntryModel>> loadJournalEntries() async {
    try {
      // 1. Lê a string JSON bruta do StorageService
      final String? jsonString = await _storageService.readData(_storageKey);

      if (jsonString != null) {
        // 2. Decodifica a string em uma Lista de mapas dinâmicos
        final List<dynamic> decodedList = json.decode(jsonString) as List;

        // 3. Mapeia a lista dinâmica para uma lista de BetJournalEntryModel
        final List<BetJournalEntryModel> entries = decodedList
            .map((item) => BetJournalEntryModel.fromJson(item as Map<String, dynamic>))
            .toList();
            
        return entries;
      }
      // Se não houver dados salvos, retorna uma lista vazia
      return [];
    } catch (e) {
      print('Erro ao carregar JournalService: $e');
      return []; // Retorna lista vazia em caso de erro
    }
  }

  /// Salva a lista completa de lançamentos do diário no armazenamento local.
  Future<void> saveJournalEntries(List<BetJournalEntryModel> entries) async {
    try {
      // 1. Mapeia a lista de Modelos para uma lista de Maps (JSON)
      final List<Map<String, dynamic>> jsonList =
          entries.map((entry) => entry.toJson()).toList();

      // 2. Codifica a lista de Mapas em uma string JSON
      final String jsonString = json.encode(jsonList);

      // 3. Salva a string JSON no StorageService
      await _storageService.saveData(_storageKey, jsonString);
    } catch (e) {
      print('Erro ao salvar JournalService: $e');
      // Tratar erro
    }
  }
}