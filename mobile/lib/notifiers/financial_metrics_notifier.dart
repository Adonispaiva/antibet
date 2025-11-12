import 'package:antibet_mobile/infra/services/financial_metrics_service.dart';
import 'package:antibet_mobile/models/financial_metrics_model.dart';
import 'package:flutter/material.dart';

/// Gerencia o estado e a lógica de negócios para as métricas financeiras avançadas.
///
/// Este Notifier utiliza o [FinancialMetricsService] para realizar cálculos
/// de performance (ROI, Balanço, etc.) e expor o resultado à UI.
class FinancialMetricsNotifier with ChangeNotifier {
  final FinancialMetricsService _metricsService;

  bool _isLoading = false;
  FinancialMetricsModel _metrics = FinancialMetricsModel.empty(); // Tipado e inicializado
  String? _errorMessage;

  // Construtor com injeção de dependência
  FinancialMetricsNotifier(this._metricsService) {
    // Carrega as métricas iniciais
    loadMetrics();
  }

  // Getters públicos
  bool get isLoading => _isLoading;
  FinancialMetricsModel get metrics => _metrics;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  
  // Getter derivado para facilitar a UI
  String get formattedROI {
    if (_metrics.totalStaked <= 0) return '0.00%';
    return (_metrics.returnOnInvestment * 100).toStringAsFixed(2) + '%';
  }

  /// Dispara o cálculo das métricas financeiras.
  /// 
  /// Este método deve ser chamado sempre que o histórico de apostas (Journal)
  /// for alterado para garantir que as métricas estejam atualizadas.
  Future<void> loadMetrics() async {
    _setStateLoading(true);

    try {
      // Chama o serviço para realizar o cálculo
      _metrics = await _metricsService.calculateMetrics();
      _errorMessage = null;

    } catch (e) {
      // TODO: Implementar logging de erro robusto.
      debugPrint('[FinancialMetricsNotifier] Erro ao calcular métricas: $e');
      _errorMessage = 'Falha ao calcular métricas financeiras.';
      _metrics = FinancialMetricsModel.empty(); // Limpa dados em caso de erro
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
      notifyListeners();
    }
  }
}