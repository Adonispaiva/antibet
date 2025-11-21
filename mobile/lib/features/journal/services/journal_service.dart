import 'package:dio/dio.dart';
import 'package:antibet/core/network/dio_provider.dart';
import 'package:antibet/features/journal/models/journal_entry_model.dart';

class JournalService {
  final Dio _dio;
  
  JournalService({Dio? dio}) : _dio = dio ?? CustomDio.instance;

  static const String _basePath = '/journal/entries';

  Future<List<JournalEntryModel>> getEntries() async {
    try {
      final response = await _dio.get(_basePath);
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> jsonList = response.data;
        return jsonList.map((json) => JournalEntryModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      rethrow; 
    }
  }

  // Assinatura corrigida para aceitar Tipos Fortes
  Future<JournalEntryModel> createEntry({
    required double amount,
    required String description,
    String type = 'bet',
  }) async {
    try {
      final response = await _dio.post(_basePath, data: {
        'amount': amount,
        'description': description,
        'type': type,
      });
      
      if (response.statusCode == 201 && response.data != null) {
        return JournalEntryModel.fromJson(response.data);
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Status: ${response.statusCode}',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<JournalEntryModel> updateEntry(String id, {
    required double amount,
    required String description,
  }) async {
    try {
      final response = await _dio.patch('$_basePath/$id', data: {
        'amount': amount,
        'description': description,
      });
      
      if (response.statusCode == 200 && response.data != null) {
        return JournalEntryModel.fromJson(response.data);
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Status: ${response.statusCode}',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      final response = await _dio.delete('$_basePath/$id');
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Falha na exclusão. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}