import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antibet/features/journal/models/journal_entry_model.dart';
import 'package:antibet/features/journal/services/journal_service.dart';

final journalServiceProvider = Provider<JournalService>((ref) {
  return JournalService();
});

final journalProvider = StateNotifierProvider.autoDispose<JournalNotifier, AsyncValue<List<JournalEntryModel>>>((ref) {
  final service = ref.watch(journalServiceProvider);
  return JournalNotifier(service);
});

class JournalNotifier extends StateNotifier<AsyncValue<List<JournalEntryModel>>> {
  final JournalService _service;

  JournalNotifier(this._service) : super(const AsyncValue.loading()) {
    getJournal();
  }

  Future<void> getJournal() async {
    if (state.isLoading == false) {
      state = const AsyncValue.loading();
    }
    try {
      final entries = await _service.getEntries();
      entries.sort((a, b) => b.date.compareTo(a.date));
      state = AsyncValue.data(entries);
    } catch (e, st) {
      state = AsyncValue.error('Falha ao carregar dados.', st);
    }
  }

  // Assinatura DEVE ser double para combinar com o Service
  Future<void> createEntry({
    required double amount,
    required String description,
    String type = 'bet',
  }) async {
    try {
      // Aqui amount é double e description é String. A ordem dos parâmetros nomeados não importa, mas os tipos sim.
      final newEntry = await _service.createEntry(
        amount: amount,
        description: description,
        type: type,
      );

      if (state.hasValue) {
        state = AsyncValue.data([newEntry, ...state.value!]);
      }
      await getJournal(); 
    } catch (e) {
      throw Exception('Falha na criação.');
    }
  }

  Future<void> updateEntry(
    String id, {
    required double amount,
    required String description,
  }) async {
    try {
      final updatedEntry = await _service.updateEntry(
        id,
        amount: amount,
        description: description,
      );

      if (state.hasValue) {
        final currentEntries = state.value!;
        final index = currentEntries.indexWhere((e) => e.id == id);
        if (index != -1) {
          final updatedList = List<JournalEntryModel>.from(currentEntries);
          updatedList[index] = updatedEntry;
          state = AsyncValue.data(updatedList);
        }
      }
    } catch (e) {
      throw Exception('Falha na atualização.');
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      await _service.deleteEntry(id);
      if (state.hasValue) {
        final updatedList = state.value!.where((e) => e.id != id).toList();
        state = AsyncValue.data(updatedList);
      }
    } catch (e) {
      throw Exception('Falha na exclusão.');
    }
  }
}