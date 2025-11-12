import 'package:antibet_mobile/infra/services/dashboard_service.dart';
import 'package:antibet_mobile/models/dashboard_summary_model.dart';
import 'package:flutter/material.dart';

/// Gerencia o estado dos dados de resumo do Dashboard.
///
/// Este Notifier utiliza o [DashboardService] para buscar e manipular
/// os dados consolidados, expondo-os para a UI através do Provider.
class DashboardNotifier with ChangeNotifier {
  final DashboardService _dashboardService;

  bool _isLoading = false;
  DashboardSummaryModel _summary = DashboardSummaryModel.empty(); // Tipado e inicializado
  String? _errorMessage;

  // Construtor com injeção de dependência
  DashboardNotifier(this._dashboardService);

  // Getters para expor o estado
  bool get isLoading => _isLoading;
  DashboardSummaryModel get summary => _summary;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Carrega os dados de resumo do dashboard.
  Future<void> loadSummary() async {
    _setStateLoading(true);

    try {
      // Chama o serviço (que agora retorna Future<DashboardSummaryModel>)
      _summary = await _dashboardService.getDashboardSummary();
      _errorMessage = null;

    } catch (e) {
      // TODO: Implementar logging de erro robusto.
      debugPrint('[DashboardNotifier] Erro ao carregar resumo: $e');
      _errorMessage = 'Falha ao carregar dados do dashboard.';
      _summary = DashboardSummaryModel.empty(); // Limpa dados em caso de erro
    } finally {
      _setStateLoading(false);
    }
  }

  // --- Métodos de controle de estado ---

  /// Controla o estado de carregamento e notifica os ouvintes.
  void _setStateLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    } else {
      // Notifica mesmo que o loading não mude (ex: erro ou sucesso)
      notifyListeners();
    }
  }
}