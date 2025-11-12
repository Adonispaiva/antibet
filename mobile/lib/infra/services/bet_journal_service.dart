import 'package:antibet_mobile/models/bet_journal_entry_model.dart';
import 'package:flutter/material.dart';

/// Camada de Serviço de Infraestrutura para o Diário de Apostas.
///
/// Responsável pela comunicação com a API (Backend) para registrar e
/// buscar o histórico de apostas do usuário.
class BetJournalService {
  // TODO: Adicionar dependência do ApiClient para comunicação real
  // final ApiClient _apiClient;
  // BetJournalService(this._apiClient);
  
  BetJournalService();

  /// Busca a lista de todas as entradas do diário de apostas do usuário.
  Future<List<BetJournalEntryModel>> fetchJournalEntries() async {
    try {
      // 1. Simulação de chamada de rede
      debugPrint('[BetJournalService] Buscando diário de apostas...');
      await Future.delayed(const Duration(milliseconds: 700));

      // 2. Simulação de dados JSON recebidos da API
      final List<Map<String, dynamic>> mockApiResponse = [
        {
          'id': 'entry_001',
          'strategyId': 'strat_123',
          'status': 'win',
          'stake': 50.00,
          'profit': 35.00,
          'entryDate': '2025-11-09T18:00:00Z',
          'notes': 'Gol HT, deu certo no último minuto do primeiro tempo.',
        },
        {
          'id': 'entry_002',
          'strategyId': 'strat_456',
          'status': 'loss',
          'stake': 100.00,
          'profit': -100.00,
          'entryDate': '2025-11-10T12:00:00Z',
          'notes': 'Empate Anula, faltou agressividade do time A.',
        },
        {
          'id': 'entry_003',
          'strategyId': 'strat_123',
          'status': 'pending',
          'stake': 75.00,
          'profit': 0.00,
          'entryDate': '2025-11-11T14:30:00Z',
          'notes': 'Ainda esperando o resultado do jogo de hoje.',
        },
      ];

      // 3. Parsing dos dados usando o BetJournalEntryModel.fromJson
      final List<BetJournalEntryModel> entries = mockApiResponse
          .map((json) => BetJournalEntryModel.fromJson(json))
          .toList();

      debugPrint('[BetJournalService] Diário de apostas recebido e parseado.');
      return entries;

    } catch (e) {
      debugPrint('[BetJournalService] Erro ao buscar diário: $e');
      throw Exception('Falha ao carregar diário de apostas.');
    }
  }

  /// Registra uma nova entrada de aposta no Backend.
  /// Retorna o modelo salvo com o ID do Backend.
  Future<BetJournalEntryModel> addJournalEntry(BetJournalEntryModel entry) async {
    try {
      // 1. Simulação de chamada de rede (POST)
      debugPrint('[BetJournalService] Enviando nova entrada: ${entry.notes}');
      await Future.delayed(const Duration(milliseconds: 800));

      // 2. Simulação de resposta da API (retorna o objeto com ID real)
      final Map<String, dynamic> mockResponse = entry.toJson();
      mockResponse['id'] = 'entry_new_${DateTime.now().millisecondsSinceEpoch}';

      debugPrint('[BetJournalService] Entrada salva com ID: ${mockResponse['id']}');
      return BetJournalEntryModel.fromJson(mockResponse);
      
    } catch (e) {
      debugPrint('[BetJournalService] Erro ao adicionar entrada: $e');
      throw Exception('Falha ao registrar aposta.');
    }
  }
}