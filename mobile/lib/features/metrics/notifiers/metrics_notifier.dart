// mobile/lib/features/metrics/notifiers/metrics_notifier.dart

import 'package:antibet/core/services/metrics_service.dart'; // O Serviço de API (Fase 3)
import 'package:antibet/features/metrics/models/metric_summary_model.dart'; // O Modelo de Dados
import 'package:flutter/foundation.dart';

/// Notifier responsável por gerenciar e expor a lista de métricas calculadas à UI.
class MetricsNotifier extends ChangeNotifier {
  final MetricsService _metricsService;

  // Estado
  List<MetricSummaryModel> _metrics = [];
  bool _isLoading = false;
  String? _errorMessage;

  MetricsNotifier(this._metricsService) {
    // Carrega as métricas na inicialização (auto-load)
    fetchMetrics();
  }

  // Getters para a UI
  List<MetricSummaryModel> get metrics => _metrics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  /// Obtém as métricas calculadas do serviço (que usa o JournalService) e atualiza o estado.
  Future<void> fetchMetrics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // O MetricsService (Fase 3) já faz o cálculo real baseado no JournalService.
      _metrics = await _metricsService.loadAllMetrics();
    } catch (e) {
      _errorMessage = 'Falha ao carregar métricas: $e';
      debugPrint('MetricsNotifier Error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Força a atualização das métricas (usado após adicionar uma nova entrada no Diário).
  Future<void> refreshMetrics() async {
      await fetchMetrics();
  }
}