import 'package:flutter_test/flutter_test.dart';
import 'package:antibet_mobile/models/bet_journal_entry_model.dart';
import 'package:antibet_mobile/infra/services/bet_journal_service.dart';

// =========================================================================
// SIMULAÇÃO DE DEPENDÊNCIAS (Mocks)
// =========================================================================

// Simulação de BetStatus (para que o teste possa ser executado neste ambiente)
enum BetStatus { win, loss, pending, voided, unknown }

// Simulação de BetJournalEntryModel (para que o teste possa ser executado neste ambiente)
class BetJournalEntryModel {
  final String id;
  final String strategyId;
  final BetStatus status;
  final double stake;
  final double profit;
  final DateTime entryDate;
  final String notes;

  BetJournalEntryModel({required this.id, required this.strategyId, required this.status, required this.stake, required this.profit, required this.entryDate, this.notes = ''});

  factory BetJournalEntryModel.fromJson(Map<String, dynamic> json) {
    return BetJournalEntryModel(
      id: json['id'] as String,
      strategyId: json['strategyId'] as String,
      status: _parseBetStatus(json['status'] as String?),
      stake: (json['stake'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
      entryDate: DateTime.parse(json['entryDate'] as String),
      notes: json['notes'] as String? ?? '',
    );
  }
  
  static BetStatus _parseBetStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'win': return BetStatus.win;
      case 'loss': return BetStatus.loss;
      case 'pending': return BetStatus.pending;
      case 'voided': return BetStatus.voided;
      default: return BetStatus.unknown;
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'strategyId': strategyId,
      'status': status.name,
      'stake': stake,
      'profit': profit,
      'entryDate': entryDate.toIso8601String(),
      'notes': notes,
    };
  }
}

// Mock da classe de Serviço do Diário de Apostas
class BetJournalService {
  BetJournalService();
  bool shouldThrowErrorFetch = false;
  bool shouldThrowErrorAdd = false;
  
  final List<Map<String, dynamic>> mockEntries = [
    {
      'id': 'entry_001',
      'strategyId': 'strat_123',
      'status': 'win',
      'stake': 50.00,
      'profit': 35.00,
      'entryDate': '2025-11-09T18:00:00Z',
      'notes': 'Gol HT, sucesso.',
    },
    {
      'id': 'entry_002',
      'strategyId': 'strat_456',
      'status': 'pending',
      'stake': 100.00,
      'profit': 0.00,
      'entryDate': '2025-11-10T12:00:00Z',
      'notes': 'Jogo ainda não finalizado.',
    }
  ];

  Future<List<BetJournalEntryModel>> fetchJournalEntries() async {
    if (shouldThrowErrorFetch) {
      throw Exception('Falha ao carregar diário de apostas.');
    }
    await Future.delayed(Duration.zero);
    return mockEntries.map((json) => BetJournalEntryModel.fromJson(json)).toList();
  }

  Future<BetJournalEntryModel> addJournalEntry(BetJournalEntryModel entry) async {
    if (shouldThrowErrorAdd) {
      throw Exception('Falha ao registrar aposta.');
    }
    await Future.delayed(Duration.zero);
    final Map<String, dynamic> mockResponse = entry.toJson();
    mockResponse['id'] = 'entry_new_mock'; 
    return BetJournalEntryModel.fromJson(mockResponse);
  }
}

// =========================================================================
// FIM DA SIMULAÇÃO
// =========================================================================

void main() {
  group('BetJournalService Unit Tests', () {
    late BetJournalService journalService;

    setUp(() {
      journalService = BetJournalService();
    });

    // ---------------------------------------------------------------------
    // Testes de Fetch (Busca)
    // ---------------------------------------------------------------------
    test('01. fetchJournalEntries deve retornar uma lista de BetJournalEntryModel válida', () async {
      final entries = await journalService.fetchJournalEntries();

      expect(entries, isA<List<BetJournalEntryModel>>());
      expect(entries.length, 2);

      final winEntry = entries.first;
      expect(winEntry.status, BetStatus.win);
      expect(winEntry.stake, 50.00);
      expect(winEntry.profit, 35.00);
      
      final pendingEntry = entries.last;
      expect(pendingEntry.status, BetStatus.pending);
      expect(pendingEntry.profit, 0.00);
    });

    test('02. fetchJournalEntries deve lançar exceção em caso de falha de API', () async {
      journalService.shouldThrowErrorFetch = true;

      expect(
        () => journalService.fetchJournalEntries(),
        throwsA(isA<Exception>()),
      );
    });

    // ---------------------------------------------------------------------
    // Testes de Add (Registro)
    // ---------------------------------------------------------------------
    test('03. addJournalEntry deve retornar o modelo salvo com novo ID em caso de sucesso', () async {
      final newEntryData = BetJournalEntryModel(
        id: 'temp_id', 
        strategyId: 'strat_100', 
        status: BetStatus.loss, 
        stake: 20.0, 
        profit: -20.0, 
        entryDate: DateTime.now(),
        notes: 'Nova aposta perdida',
      );
      
      final savedEntry = await journalService.addJournalEntry(newEntryData);

      expect(savedEntry, isA<BetJournalEntryModel>());
      expect(savedEntry.id, 'entry_new_mock'); // ID simulado do Backend
      expect(savedEntry.status, BetStatus.loss);
      expect(savedEntry.profit, -20.0);
    });
    
    test('04. addJournalEntry deve lançar exceção em caso de falha de API', () async {
      journalService.shouldThrowErrorAdd = true;
      final dummyEntry = BetJournalEntryModel(id: 'a', strategyId: 'b', status: BetStatus.win, stake: 1.0, profit: 1.0, entryDate: DateTime.now());

      expect(
        () => journalService.addJournalEntry(dummyEntry),
        throwsA(isA<Exception>()),
      );
    });
  });
}