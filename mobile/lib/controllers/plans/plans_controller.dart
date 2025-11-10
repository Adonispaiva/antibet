import 'package:flutter/material.dart';
import 'package:antibet_mobileapp/services/plans_service.dart';
// import 'package:url_launcher/url_launcher.dart'; // Futuramente: Adicionar ao pubspec.yaml

// Modelo de Dados (Mantido)
class PlanModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int aiTokens;
  final String stripePriceId;

  PlanModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        name = json['name'] as String,
        description = json['description'] as String,
        price = json['price'] is int
            ? (json['price'] as int).toDouble()
            : json['price'] as double,
        aiTokens = json['aiTokens'] as int,
        stripePriceId = json['stripePriceId'] as String;
}

class PlansController extends ChangeNotifier {
  final PlansService _plansService = PlansService();
  
  // ... [Variáveis e método fetchPlans - Mantidos] ...
  List<PlanModel> _plans = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PlanModel> get plans => _plans;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  PlansController() {
    fetchPlans();
  }
  
  Future<void> fetchPlans() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _plansService.fetchPlans();
      _plans = data.map((json) => PlanModel.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = e.toString().contains('Falha')
          ? 'Falha ao carregar planos. Tente novamente.'
          : e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  /// Inicia o fluxo de checkout e abre o navegador para o Stripe.
  Future<void> startCheckout(String planId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final checkoutUrl = await _plansService.initiateCheckout(planId);
      
      // Simulação da chamada ao pacote url_launcher
      // O ideal é usar: await launchUrl(Uri.parse(checkoutUrl), mode: LaunchMode.externalApplication);
      print('=== REDIRECIONANDO PARA O STRIPE ===');
      print('URL de Checkout: $checkoutUrl');
      print('====================================');
      
      // Feedback visual
      _errorMessage = 'Redirecionamento para o Stripe iniciado com sucesso.';

    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}