import 'package:flutter/material.dart';
import 'package:mobile/infra/services/dashboard_service.dart';
import 'package:mobile/infra/services/dashboard_service.dart' show DashboardModel;

// O DashboardNotifier gerencia o estado e os dados exibidos no Dashboard/Home
// do usuário.
class DashboardNotifier extends ChangeNotifier {
  final DashboardService _dashboardService;

  // Variáveis de Estado
  DashboardModel? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;

  // Construtor com injeção de dependência
  DashboardNotifier(this._dashboardService);

  // Getters para acessar o estado
  DashboardModel? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Define o estado de carregamento
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Define a mensagem de erro
  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  // 1. Busca o conteúdo completo do dashboard
  Future<void> fetchDashboardContent() async {
    if (_isLoading) return;

    _setLoading(true);
    _setErrorMessage(null);

    try {
      final data = await _dashboardService.fetchDashboardContent();
      _dashboardData = data;
    } catch (e) {
      _setErrorMessage('Não foi possível carregar os dados do Dashboard. Tente novamente.');
      _dashboardData = null;
    } finally {
      _setLoading(false);
    }
  }

  // 2. Simulação de um refresh de dados (que pode ser acionado via pull-to-refresh)
  Future<void> refreshData() async {
    // Apenas faz o fetch novamente sem mostrar o loading global, para uma UX melhor.
    _setErrorMessage(null);
    try {
      final data = await _dashboardService.fetchDashboardContent();
      _dashboardData = data;
    } catch (e) {
      _setErrorMessage('Falha ao atualizar os dados.');
    } finally {
      // Notifica Widgets que dependem dos dados
      notifyListeners(); 
    }
  }
}