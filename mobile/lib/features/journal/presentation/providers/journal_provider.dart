import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antibet/features/journal/data/models/journal_model.dart';
import 'package:antibet/features/journal/data/models/journal_entry_model.dart';
import 'package:antibet/features/journal/data/services/journal_service.dart';

/// Notifier que gerencia o estado do Diário (Lista de apostas + Estatísticas).
/// O estado é gerenciado como um AsyncValue<JournalModel> para facilitar o tratamento de Loading/Error/Data na UI.
class JournalNotifier extends StateNotifier<AsyncValue<JournalModel>> {
  final JournalService _service;

  JournalNotifier(this._service) : super(const AsyncValue.loading()) {
    // Carrega o diário automaticamente ao inicializar
    getJournal();
  }

  /// Busca os dados do diário na API.
  Future<void> getJournal() async {
    try {
      state = const AsyncValue.loading();
      final journal = await _service.getJournal();
      state = AsyncValue.data(journal);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Cria uma nova entrada. Retorna true em caso de sucesso.
  Future<bool> createEntry(String description, double amount, bool isWin) async {
    try {
      // Opcional: Poderíamos setar state = loading aqui se quisermos bloquear a UI inteira,
      // mas geralmente queremos apenas bloquear o botão de salvar (feito na UI via state.isLoading).
      
      await _service.createEntry(description, amount, isWin);
      
      // Atualiza a lista após criar (refresh strategy)
      // Isso garante que as estatísticas (total apostado, etc) venham calculadas do backend.
      await getJournal();
      return true;
    } catch (e) {
      // Em caso de erro, mantemos o estado atual (lista) mas podemos notificar via log
      // O erro específico é capturado na UI através do retorno 'false' ou de um provider de erro separado se desejado.
      return false;
    }
  }

  /// Atualiza uma entrada existente. Retorna true em caso de sucesso.
  Future<bool> updateEntry(JournalEntryModel entry) async {
    try {
      await _service.updateEntry(entry);
      await getJournal(); // Recarrega para atualizar estatísticas
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove uma entrada. Retorna true em caso de sucesso.
  Future<bool> deleteEntry(String id) async {
    try {
      await _service.deleteEntry(id);
      await getJournal(); // Recarrega para atualizar estatísticas
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Provider global do JournalNotifier.
final journalProvider = StateNotifierProvider<JournalNotifier, AsyncValue<JournalModel>>((ref) {
  final service = ref.read(journalServiceProvider);
  return JournalNotifier(service);
});