import 'package:antibet/core/models/bet_journal_entry_model.dart';
import 'package:antibet/core/services/storage_service.dart';

class BetJournalService {
  final StorageService _storageService;
  static const String _journalKey = 'bet_journal_entries';

  BetJournalService(this._storageService);

  /// Carrega todas as entradas do diário de apostas do armazenamento.
  /// Retorna uma lista vazia se não houver dados.
  List<BetJournalEntryModel> loadEntries() {
    return _storageService.loadList<BetJournalEntryModel>(
      _journalKey,
      BetJournalEntryModel.fromJson,
    );
  }

  /// Salva uma nova entrada no diário e a persiste no armazenamento.
  Future<bool> saveEntry(BetJournalEntryModel newEntry) async {
    // 1. Carrega a lista atual
    final currentEntries = loadEntries();
    
    // 2. Adiciona a nova entrada no início (para mostrar as mais recentes primeiro)
    final updatedEntries = [newEntry, ...currentEntries];
    
    // 3. Salva a lista atualizada
    return await _storageService.saveList<BetJournalEntryModel>(
      _journalKey,
      updatedEntries,
      (entry) => entry.toJson(),
    );
  }

  /// Remove uma entrada existente.
  Future<bool> removeEntry(String entryId) async {
    final currentEntries = loadEntries();
    final updatedEntries = currentEntries.where((entry) => entry.id != entryId).toList();
    
    return await _storageService.saveList<BetJournalEntryModel>(
      _journalKey,
      updatedEntries,
      (entry) => entry.toJson(),
    );
  }

  /// Limpa todas as entradas do diário.
  Future<bool> clearAllEntries() async {
    return await _storageService.remove(_journalKey);
  }
}