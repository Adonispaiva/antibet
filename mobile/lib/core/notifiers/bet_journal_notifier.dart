import 'package:flutter/foundation.dart';
import 'package:antibet/core/models/bet_journal_entry_model.dart'; // Pressupondo que o caminho é este

/// Notifier responsável por gerenciar a lista de lançamentos do diário de apostas.
/// Esta classe define o estado central dos dados de apostas do usuário.
class BetJournalNotifier extends ChangeNotifier {
  // Lista privada mutável que armazena todos os lançamentos do diário.
  final List<BetJournalEntryModel> _entries = [];

  // Getter público para acessar a lista de lançamentos de forma imutável.
  // Retorna uma cópia da lista ou lista vazia se for nula, garantindo segurança.
  List<BetJournalEntryModel> get entries => List.unmodifiable(_entries);
  
  // Propriedade de exemplo para calcular estatísticas rápidas.
  int get totalEntries => _entries.length;

  /// Adiciona um novo lançamento ao diário e notifica os ouvintes.
  Future<void> addEntry(BetJournalEntryModel newEntry) async {
    // Simulação de delay para operação de persistência (StorageService).
    await Future.delayed(const Duration(milliseconds: 300));

    // Adiciona o novo lançamento.
    _entries.add(newEntry);

    // Ordena a lista, por exemplo, por data de forma decrescente.
    //_entries.sort((a, b) => b.date.compareTo(a.date));

    // Notifica a UI sobre a alteração do estado.
    notifyListeners();
  }

  // Futuramente, serão adicionados métodos para:
  // - fetchEntries(): Carregar dados do StorageService.
  // - updateEntry(): Atualizar um lançamento existente.
  // - deleteEntry(): Remover um lançamento.
}