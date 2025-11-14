// mobile/lib/core/services/journal_api_service.dart

import 'dart:convert';
import 'package:antibet/core/services/auth_service.dart';
import 'package:antibet/features/journal/models/journal_entry_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:antibet/config/app_config.dart'; // Importação do AppConfig

// const String _kApiUrl = 'http://localhost:3000/api/journal'; // Removido!

class JournalApiService {
  final AuthService _authService;

  JournalApiService(this._authService);

  /// Helper para construir os headers com o Token JWT.
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Autenticação necessária para acessar o Diário.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Injeção do token JWT
    };
  }

  /// Cria uma nova entrada no Backend (POST).
  Future<JournalEntryModel> createEntry(JournalEntryModel entry) async {
    final url = Uri.parse('${AppConfig.apiUrl}/journal'); // Usando AppConfig

    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(entry.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return JournalEntryModel.fromJson(data);
      }
      
      debugPrint('JournalApiService: Falha ao criar. Status: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Falha na criação da entrada no diário.');
    } catch (e) {
      debugPrint('JournalApiService: Erro de conexão ao criar entrada: $e');
      rethrow;
    }
  }

  /// Obtém a lista de entradas do Backend com filtros (GET).
  Future<List<JournalEntryModel>> getEntriesWithFilter(Map<String, String> filters) async {
    // Constrói a URL com filtros (Query Params)
    final uri = Uri.parse('${AppConfig.apiUrl}/journal').replace(queryParameters: filters); // Usando AppConfig
    
    try {
      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => JournalEntryModel.fromJson(item)).toList();
      }
      
      debugPrint('JournalApiService: Falha ao buscar. Status: ${response.statusCode}');
      throw Exception('Falha ao carregar entradas do diário.');
    } catch (e) {
      debugPrint('JournalApiService: Erro de conexão ao buscar entradas: $e');
      rethrow;
    }
  }

  /// Atualiza uma entrada existente no Backend (PATCH).
  Future<JournalEntryModel> updateEntry(JournalEntryModel updatedEntry) async {
    final url = Uri.parse('${AppConfig.apiUrl}/journal/${updatedEntry.id}'); // Usando AppConfig
    
    try {
      final response = await http.patch(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(updatedEntry.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return JournalEntryModel.fromJson(data);
      }
      
      debugPrint('JournalApiService: Falha ao atualizar. Status: ${response.statusCode}');
      throw Exception('Falha na atualização da entrada.');
    } catch (e) {
      debugPrint('JournalApiService: Erro de conexão ao atualizar entrada: $e');
      rethrow;
    }
  }

  /// Remove uma entrada pelo ID no Backend (DELETE).
  Future<void> deleteEntry(int entryId) async {
    final url = Uri.parse('${AppConfig.apiUrl}/journal/$entryId'); // Usando AppConfig
    
    try {
      final response = await http.delete(
        url,
        headers: await _getHeaders(),
      );

      if (response.statusCode != 204) { // 204 No Content é o esperado para DELETE
        debugPrint('JournalApiService: Falha ao deletar. Status: ${response.statusCode}');
        throw Exception('Falha ao deletar entrada.');
      }
    } catch (e) {
      debugPrint('JournalApiService: Erro de conexão ao deletar entrada: $e');
      rethrow;
    }
  }
}