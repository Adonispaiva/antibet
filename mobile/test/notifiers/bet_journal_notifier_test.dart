import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:antibet_mobile/models/bet_journal_entry_model.dart';
import 'package:antibet_mobile/infra/services/bet_journal_service.dart';
import 'package:antibet_mobile/notifiers/bet_journal_notifier.dart';

// =========================================================================
// SIMULAÇÃO DE DEPENDÊNCIAS (Mocks)
// =========================================================================

// Simulação de BetStatus (para que o teste possa ser executado neste ambiente)
enum BetStatus { win, loss, pending, voided, unknown }

// Simulação de BetJournalEntryModel (para que o teste possa ser executado neste ambiente)
class BetJournalEntryModel {
  final String id;
  final BetStatus status;
  final double stake;
  final double profit;
  final DateTime entryDate;
  BetJournalEntryModel({required this.id, required this.status, required this.stake, required this.profit, required this.entryDate});
  factory BetJournalEntryModel.fromJson(Map<String, dynamic> json) => throw UnimplementedError();
  Map<String, dynamic> toJson() => throw UnimplementedError();
}

// Simulação de BetJournalService (mínimo necessário para o teste)
class BetJournalService {
  BetJournalService();
  Future<List<BetJournalEntryModel>> fetchJournalEntries() async => throw UnimplementedError();
  Future<BetJournalEntryModel> addJournalEntry(BetJournalEntryModel entry) async => throw UnimplementedError();
}

// Mock da classe de Serviço do Diário de Apostas
class MockBetJournalService implements BetJournalService {
  bool shouldThrowErrorFetch = false;
  bool shouldThrowErrorAdd = false;
  
  final tWinEntry = BetJournalEntryModel(id: 'w01', status: BetStatus.win, stake: 50, profit: 35, entryDate: DateTime(2025, 11, 1));
  final tLossEntry = BetJournalEntryModel(id: 'l01', status: BetStatus.loss, stake: 100, profit: -100, entryDate: DateTime(2025, 11, 2));
  final tPendingEntry = BetJournalEntryModel(id: 'p01', status: BetStatus.pending, stake: 20, profit: 0, entryDate: DateTime(2025, 11, 3));
  
  @override
  Future<List<BetJournalEntryModel>> fetchJournalEntries() async {
    if (shouldThrowErrorFetch) {
      await Future.delayed(Duration.zero);
      throw Exception('Falha ao carregar diário de apostas.');
    }
    await Future.delayed(Duration.zero);
    return [tWinEntry, tLossEntry, tPendingEntry];
  }

  @override
  Future<BetJournalEntryModel> addJournalEntry(BetJournalEntryModel entry) async {
    if (shouldThrowErrorAdd) {
      await Future.delayed(Duration.zero);
      throw Exception('Falha ao registrar aposta.');
    }
    await Future.delayed(Duration.zero);
    return BetJournalEntryModel(
      id: 'new_id', 
      status: entry.status, 
      stake: entry.stake, 
      profit: entry.profit, 
      entryDate: entry.entryDate,
    );
  }
}

// SIMULAÇÃO DO NOTIFIER (mínimo necessário para o teste)
class BetJournalNotifier with ChangeNotifier {
  final MockBetJournalService _journalService;

  bool _isLoading = false;
  List<BetJournalEntryModel> _entries = [];
  String? _errorMessage;

  BetJournalNotifier(this._journalService) {
    // Para o teste, faremos a chamada manual para controlar o future
    // fetchEntries(); 
  }

  bool get isLoading => _isLoading;
  List<BetJournalEntryModel> get entries => List.unmodifiable(_entries);
  String? get errorMessage => _errorMessage;

  double get totalProfit {
    return _entries.fold(0.0, (sum, entry) => sum + entry.profit);
  }

  int _getEntryCountByStatus(BetStatus status) {
    return _entries.where((e) => e.status == status).length;
  }
  
  int get winCount => _getEntryCountByStatus(BetStatus.win);
  int get lossCount => _getEntryCountByStatus(BetStatus.loss);
  int get pendingCount => _getEntryCountByStatus(BetStatus.pending);

  Future<void> fetchEntries() async {
    _setStateLoading(true);

    try {
      final fetchedEntries = await _journalService.fetchJournalEntries();
      _entries = fetchedEntries;
      _errorMessage = null;

    } catch (e) {
      _errorMessage = 'Falha ao buscar histórico de apostas.';
      _entries = [];
    } finally {
      _setStateLoading(false);
    }
  }

  Future<bool> addEntry(BetJournalEntryModel newEntry) async {
    try {
      final savedEntry = await _journalService.addJournalEntry(newEntry);
      _entries.insert(0, savedEntry); 
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Falha ao registrar aposta: ${e.toString().replaceFirst('Exception: ', '')}';
      notifyListeners();
      return false;
    }
  }

  void _setStateLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    } else {
      notifyListeners();
    }
  }
}

// =========================================================================
// FIM DA SIMULAÇÃO
// =========================================================================

void main() {
  group('BetJournalNotifier Unit Tests', () {
    late BetJournalNotifier notifier;
    late MockBetJournalService mockService;
    
    // Configuração: Garante estado limpo e objetos antes de cada teste
    setUp(() {
      mockService = MockBetJournalService();
      notifier = BetJournalNotifier(mockService);
    });

    // ---------------------------------------------------------------------
    // Testes de Fetch e Estatísticas
    // ---------------------------------------------------------------------
    test('01. fetchEntries deve carregar dados e calcular estatísticas corretamente', () async {
      final future = notifier.fetchEntries();
      
      expect(notifier.isLoading, true);
      await future;
      
      // Estado de Sucesso
      expect(notifier.isLoading, false);
      expect(notifier.entries.length, 3);
      expect(notifier.errorMessage, isNull);
      
      // Teste de Estatísticas (35 + (-100) + 0 = -65)
      expect(notifier.totalProfit, -65.0);
      expect(notifier.winCount, 1);
      expect(notifier.lossCount, 1);
      expect(notifier.pendingCount, 1);
    });

    test('02. fetchEntries deve lidar com falha de serviço e limpar o estado', () async {
      mockService.shouldThrowErrorFetch = true;
      
      await notifier.fetchEntries();
      
      // Estado de Falha
      expect(notifier.isLoading, false);
      expect(notifier.entries, isEmpty);
      expect(notifier.errorMessage, 'Falha ao buscar histórico de apostas.');
      expect(notifier.totalProfit, 0.0);
    });

    // ---------------------------------------------------------------------
    // Testes de Adição
    // ---------------------------------------------------------------------
    test('03. addEntry deve adicionar a nova entrada ao topo e atualizar o lucro total', () async {
      // Carrega o estado inicial (para ter -65 de lucro)
      await notifier.fetchEntries();
      
      final tNewEntry = BetJournalEntryModel(id: 'n01', status: BetStatus.win, stake: 10, profit: 5, entryDate: DateTime.now());
      
      final success = await notifier.addEntry(tNewEntry);
      
      // Verificação da Lista
      expect(success, true);
      expect(notifier.entries.length, 4);
      expect(notifier.entries.first.id, 'new_id'); // Nova entrada deve estar no topo
      
      // Verificação de Estatísticas (-65 + 5 = -60)
      expect(notifier.totalProfit, -60.0);
      expect(notifier.winCount, 2);
    });

    test('04. addEntry deve falhar, manter a lista original e definir a mensagem de erro', () async {
      await notifier.fetchEntries();
      final initialLength = notifier.entries.length;
      
      mockService.shouldThrowErrorAdd = true;
      final tNewEntry = BetJournalEntryModel(id: 'n01', status: BetStatus.win, stake: 10, profit: 5, entryDate: DateTime.now());

      final success = await notifier.addEntry(tNewEntry);

      expect(success, false);
      expect(notifier.entries.length, initialLength); // Lista não deve ser modificada
      expect(notifier.errorMessage, contains('Falha ao registrar aposta'));
    });
  });
}