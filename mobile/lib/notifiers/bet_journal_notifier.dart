import 'package:antibet_mobile/infra/services/bet_journal_service.dart';
import 'package:antibet_mobile/models/bet_journal_entry_model.dart';
import 'package:flutter/material.dart';

/// Gerencia o estado e a lógica de negócios para o Diário de Apostas do usuário.
///
/// Responsável por manter a lista de entradas, calcular estatísticas e
/// coordenar o serviço para persistência e busca.
class BetJournalNotifier with ChangeNotifier {
  final BetJournalService _journalService;

  bool _isLoading = false;
  List<BetJournalEntryModel> _entries = [];
  String? _errorMessage;

  // Construtor com injeção de dependência
  BetJournalNotifier(this._journalService) {
    // Carrega o histórico ao iniciar o Notifier
    fetchEntries();
  }

  // Getters públicos
  bool get isLoading => _isLoading;
  List<BetJournalEntryModel> get entries => List.unmodifiable(_entries);
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  // --- Getters de Estatísticas Consolidadas ---

  /// Calcula e retorna o lucro/prejuízo total do diário.
  double get totalProfit {
    return _entries.fold(0.0, (sum, entry) => sum + entry.profit);
  }

  /// Retorna o número de apostas em um status específico.
  int _getEntryCountByStatus(BetStatus status) {
    return _entries.where((e) => e.status == status).length;
  }
  
  int get winCount => _getEntryCountByStatus(BetStatus.win);
  int get lossCount => _getEntryCountByStatus(BetStatus.loss);
  int get pendingCount => _getEntryCountByStatus(BetStatus.pending);

  // --- Métodos de Ação ---

  /// Busca o histórico completo de apostas do serviço.
  Future<void> fetchEntries() async {
    _setStateLoading(true);

    try {
      final fetchedEntries = await _journalService.fetchJournalEntries();
      _entries = fetchedEntries;
      _errorMessage = null;

    } catch (e) {
      debugPrint('[BetJournalNotifier] Erro ao carregar diário: $e');
      _errorMessage = 'Falha ao buscar histórico de apostas.';
      _entries = []; // Limpa dados em caso de erro
    } finally {
      _setStateLoading(false);
    }
  }

  /// Adiciona uma nova entrada ao diário.
  Future<bool> addEntry(BetJournalEntryModel newEntry) async {
    // Estado de loading não é ativado aqui para não bloquear o fetch
    // Se a UI for simples, poderíamos usar um estado de 'isSaving'
    try {
      final savedEntry = await _journalService.addJournalEntry(newEntry);
      
      // Adiciona a entrada salva (com ID real) ao topo da lista e notifica
      _entries.insert(0, savedEntry); 
      _errorMessage = null;
      notifyListeners();
      return true;

    } catch (e) {
      debugPrint('[BetJournalNotifier] Erro ao adicionar entrada: $e');
      _errorMessage = 'Falha ao registrar aposta: ${e.toString().replaceFirst('Exception: ', '')}';
      notifyListeners();
      return false;
    }
  }

  /// Controla o estado de carregamento e notifica os ouvintes.
  void _setStateLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    } else {
      notifyListeners(); // Notifica em caso de erro/sucesso se o loading não mudou
    }
  }
}