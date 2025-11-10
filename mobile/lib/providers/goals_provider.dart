import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:inovexa_antibet/models/goal.model.dart';
import 'package:inovexa_antibet/providers/auth_provider.dart';
import 'package:inovexa_antibet/services/api_service.dart';

class GoalsProvider with ChangeNotifier {
  final AuthProvider _authProvider; // Dependência para o token

  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Goal> get goals => List.unmodifiable(_goals);
  bool get isLoading => _isLoading;
  String? get error => _error;

  GoalsProvider(this._authProvider) {
    // Se o usuário estiver autenticado, busca as metas imediatamente
    if (_authProvider.isAuthenticated) {
      fetchGoals();
    }
  }

  /// Busca as metas do usuário na API
  Future<void> fetchGoals() async {
    if (_authProvider.token == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await apiService.dio.get('/goals');
      final List<dynamic> data = response.data;
      _goals = data.map((json) => Goal.fromJson(json)).toList();
    } on DioException catch (e) {
      _error = 'Falha ao buscar metas: ${e.message}';
    } catch (e) {
      _error = 'Ocorreu um erro inesperado.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adiciona uma nova meta
  Future<bool> addGoal(Map<String, dynamic> goalData) async {
    if (_authProvider.token == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await apiService.dio.post('/goals', data: goalData);
      final newGoal = Goal.fromJson(response.data);
      _goals.insert(0, newGoal); // Adiciona no início da lista
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = 'Falha ao adicionar meta: ${e.message}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Atualiza o status (ou outros campos) de uma meta
  Future<bool> updateGoal(String goalId, Map<String, dynamic> updateData) async {
    if (_authProvider.token == null) return false;
    // Não ativa o loading global para atualizações rápidas (ex: checkbox)

    try {
      final response = await apiService.dio.patch(
        '/goals/$goalId',
        data: updateData,
      );
      final updatedGoal = Goal.fromJson(response.data);
      
      // Atualiza na lista local
      final index = _goals.indexWhere((g) => g.id == goalId);
      if (index != -1) {
        _goals[index] = updatedGoal;
        notifyListeners();
      }
      return true;
    } on DioException catch (e) {
      _error = 'Falha ao atualizar meta: ${e.message}';
      notifyListeners();
      return false;
    }
  }

  /// Deleta uma meta
  Future<void> deleteGoal(String goalId) async {
    if (_authProvider.token == null) return;

    try {
      await apiService.dio.delete('/goals/$goalId');
      _goals.removeWhere((g) => g.id == goalId);
      notifyListeners();
    } on DioException catch (e) {
      _error = 'Falha ao deletar meta: ${e.message}';
      notifyListeners();
    }
  }
}