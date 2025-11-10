import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:inovexa_antibet/models/plan.model.dart';
import 'package:inovexa_antibet/providers/auth_provider.dart'; // (Novo)
import 'package:inovexa_antibet/services/api_service.dart';

class PlansProvider with ChangeNotifier {
  // (Novo) Injeta o AuthProvider para o token
  final AuthProvider? _authProvider;

  List<Plan> _plans = [];
  bool _isLoading = true;
  String? _error;

  String? _checkoutUrl;
  String? _checkoutError;
  bool _isCheckoutLoading = false;

  // Getters
  List<Plan> get plans => List.unmodifiable(_plans);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get checkoutUrl => _checkoutUrl;
  String? get checkoutError => _checkoutError;
  bool get isCheckoutLoading => _isCheckoutLoading;

  PlansProvider(this._authProvider) {
    fetchPlans();
  }

  /// (v1.0) Busca a lista de planos disponíveis
  Future<void> fetchPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await apiService.dio.get('/plans');
      _plans = (response.data as List).map((json) => Plan.fromJson(json)).toList();
    } on DioException catch (e) {
      _error = 'Falha ao buscar planos: ${e.message}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// (Novo) Tenta criar uma sessão de checkout no Backend
  Future<String?> createCheckoutSession(String planId) async {
    // Garante que o usuário está logado (o token já está no apiService)
    if (_authProvider == null || !_authProvider.isAuthenticated) {
      _checkoutError = 'Você precisa estar logado para fazer upgrade.';
      notifyListeners();
      return null;
    }

    _isCheckoutLoading = true;
    _checkoutUrl = null;
    _checkoutError = null;
    notifyListeners();

    try {
      final response = await apiService.dio.post(
        '/payments/create-checkout-session',
        data: {'planId': planId},
      );

      if (response.data['url'] != null) {
        _checkoutUrl = response.data['url'];
        return _checkoutUrl;
      } else {
        throw Exception('URL de checkout não retornada.');
      }
    } on DioException catch (e) {
      _checkoutError = 'Falha ao iniciar pagamento: ${e.response?.data['message'] ?? e.message}';
      return null;
    } catch (e) {
      _checkoutError = 'Erro inesperado: $e';
      return null;
    } finally {
      _isCheckoutLoading = false;
      notifyListeners();
    }
  }
}