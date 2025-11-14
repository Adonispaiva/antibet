// mobile/lib/features/journal/notifiers/journal_notifier.dart

import 'package:antibet/core/services/journal_api_service.dart'; // O Serviço de API
import 'package:antibet/features/journal/models/journal_entry_model.dart'; // O Modelo de Dados
import 'package:flutter/foundation.dart';

/// Notifier responsável por gerenciar e expor a lista de entradas de diário do usuário à UI.
class JournalNotifier extends ChangeNotifier {
  final JournalApiService _journalApiService;

  // Estado
  List<JournalEntryModel> _entries = [];
  bool _isLoading = false;
  String? _errorMessage;

  JournalNotifier(this._journalApiService) {
    // Carrega as entradas na inicialização (auto-load)
    fetchEntries();
  }

  // Getters para a UI
  List<JournalEntryModel> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  /// Obtém a lista de entradas do serviço (API) e atualiza o estado.
  /// Aceita filtros para buscas específicas.
  Future<void> fetchEntries({Map<String, String>? filters}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _entries = await _journalApiService.getEntriesWithFilter(filters ?? {});
      // Ordena por data (mais recente primeiro, como é padrão no diário)
      _entries.sort((a, b) => b.entryDate.compareTo(a.entryDate)); 
    } catch (e) {
      _errorMessage = 'Falha ao carregar entradas: $e';
      debugPrint('JournalNotifier Error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adiciona uma nova entrada e atualiza a lista no Backend e localmente.
  Future<void> addEntry(JournalEntryModel entry) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Cria no Backend (via Service)
      final newEntry = await _journalApiService.createEntry(entry);
      
      // 2. Atualiza o estado local, inserindo no topo (mais recente)
      _entries.insert(0, newEntry);
      
      debugPrint('JournalNotifier: Entrada adicionada localmente: ID ${newEntry.id}');
    } catch (e) {
      _errorMessage = 'Falha ao adicionar entrada: $e';
      debugPrint('JournalNotifier Error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Atualiza uma entrada existente (ex: adiciona pós-análise) e atualiza o Backend.
  Future<void> updateEntry(JournalEntryModel updatedEntry) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Atualiza no Backend (via Service)
      final result = await _journalApiService.updateEntry(updatedEntry);
      
      // 2. Atualiza o estado local
      final index = _entries.indexWhere((e) => e.id == updatedEntry.id);
      if (index != -1) {
        _entries[index] = result;
      }
      
      debugPrint('JournalNotifier: Entrada atualizada localmente: ID ${result.id}');
    } catch (e) {
      _errorMessage = 'Falha ao atualizar entrada: $e';
      debugPrint('JournalNotifier Error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Remove uma entrada e atualiza o estado.
  Future<void> removeEntry(int entryId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Remove no Backend (via Service)
      await _journalApiService.deleteEntry(entryId);
      
      // 2. Remove do estado local
      _entries.removeWhere((e) => e.id == entryId);
      
      debugPrint('JournalNotifier: Entrada removida localmente: ID $entryId');
    } catch (e) {
      _errorMessage = 'Falha ao remover entrada: $e';
      debugPrint('JournalNotifier Error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}