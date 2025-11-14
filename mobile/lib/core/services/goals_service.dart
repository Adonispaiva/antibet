// mobile/lib/core/services/goals_service.dart

import 'dart:convert';
import 'package:antibet/core/services/auth_service.dart';
import 'package:antibet/features/goals/models/goal_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// A URL da API do Backend.
const String _kApiUrl = 'http://localhost:3000/api/goals';

class GoalsService {
  final AuthService _authService;

  GoalsService(this._authService);

  /// Helper para construir os headers com o Token JWT.
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Autenticação necessária para acessar Metas.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Injeção do token JWT
    };
  }

  /// Cria uma nova meta no Backend (POST).
  Future<GoalModel> addGoal(GoalModel goal) async {
    final url = Uri.parse(_kApiUrl);
    
    // Converte o modelo GoalModel para JSON.
    // O backend deve ignorar o 'id' e 'currentAmount' se não fornecido.
    final goalJson = goal.toJson();

    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(goalJson),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return GoalModel.fromJson(data);
      }
      
      debugPrint('GoalsService: Falha ao criar meta. Status: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Falha na criação da meta financeira.');
    } catch (e) {
      debugPrint('GoalsService: Erro de conexão ao criar meta: $e');
      rethrow;
    }
  }

  /// Obtém a lista de metas do Backend (GET).
  Future<List<GoalModel>> getGoals() async {
    final url = Uri.parse(_kApiUrl);
    
    try {
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => GoalModel.fromJson(item)).toList();
      }
      
      debugPrint('GoalsService: Falha ao buscar metas. Status: ${response.statusCode}');
      throw Exception('Falha ao carregar metas financeiras.');
    } catch (e) {
      debugPrint('GoalsService: Erro de conexão ao buscar metas: $e');
      rethrow;
    }
  }

  /// Atualiza uma meta existente no Backend (PATCH).
  Future<GoalModel> updateGoal(GoalModel updatedGoal) async {
    final url = Uri.parse('$_kApiUrl/${updatedGoal.id}');
    
    try {
      final response = await http.patch(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(updatedGoal.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GoalModel.fromJson(data);
      }
      
      debugPrint('GoalsService: Falha ao atualizar meta. Status: ${response.statusCode}');
      throw Exception('Falha na atualização da meta.');
    } catch (e) {
      debugPrint('GoalsService: Erro de conexão ao atualizar meta: $e');
      rethrow;
    }
  }

  /// Remove uma meta pelo ID no Backend (DELETE).
  Future<void> removeGoal(int goalId) async {
    final url = Uri.parse('$_kApiUrl/$goalId');
    
    try {
      final response = await http.delete(
        url,
        headers: await _getHeaders(),
      );

      if (response.statusCode != 204) { // 204 No Content é o esperado para DELETE
        debugPrint('GoalsService: Falha ao deletar meta. Status: ${response.statusCode}');
        throw Exception('Falha ao deletar meta.');
      }
    } catch (e) {
      debugPrint('GoalsService: Erro de conexão ao deletar meta: $e');
      rethrow;
    }
  }
}