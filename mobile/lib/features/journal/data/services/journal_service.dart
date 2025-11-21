import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antibet/core/network/dio_provider.dart';
import 'package:antibet/features/journal/data/models/journal_model.dart';
import 'package:antibet/features/journal/data/models/journal_entry_model.dart';

/// Serviço responsável pelas operações CRUD do Diário.
class JournalService {
  final Dio _dio;

  JournalService(this._dio);

  /// Obtém o diário completo do usuário (lista de apostas e estatísticas).
  Future<JournalModel> getJournal() async {
    try {
      final response = await _dio.get('/journal');
      return JournalModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Cria uma nova entrada no diário.
  Future<JournalEntryModel> createEntry(String description, double amount, bool isWin) async {
    try {
      final response = await _dio.post('/journal/entries', data: {
        'description': description,
        'amount': amount,
        'isWin': isWin,
        'date': DateTime.now().toIso8601String(), // Envia a data atual
      });
      return JournalEntryModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Atualiza uma entrada existente.
  Future<JournalEntryModel> updateEntry(JournalEntryModel entry) async {
    try {
      final response = await _dio.put('/journal/entries/${entry.id}', data: {
        'description': entry.description,
        'amount': entry.amount,
        'isWin': entry.isWin,
      });
      return JournalEntryModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Exclui uma entrada pelo ID.
  Future<void> deleteEntry(String id) async {
    try {
      await _dio.delete('/journal/entries/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final message = e.response?.data['message'] ?? 'Erro ao processar solicitação no diário.';
      return Exception(message);
    }
    return Exception('Erro de conexão ao acessar o diário.');
  }
}

/// Provider global para acessar o JournalService.
final journalServiceProvider = Provider<JournalService>((ref) {
  final dio = ref.read(dioProvider);
  return JournalService(dio);
});