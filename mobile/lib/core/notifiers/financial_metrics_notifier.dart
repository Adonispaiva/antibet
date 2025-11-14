import 'package:flutter/foundation.dart';
import 'package:antibet/core/models/financial_metrics_model.dart'; // Pressupondo que o caminho é este

/// Notifier responsável por gerenciar e expor o estado das métricas financeiras
/// globais do usuário, como ROI, lucro total e taxa de acerto.
class FinancialMetricsNotifier extends ChangeNotifier {
  // Estado privado que armazena as métricas financeiras.
  FinancialMetricsModel _metrics = FinancialMetricsModel(
    totalProfit: 0.0,
    roi: 0.0,
    hitRate: 0.0,
  );

  // Getter público para acesso imutável às métricas.
  FinancialMetricsModel get metrics => _metrics;

  /// Atualiza o estado das métricas financeiras.
  /// No futuro, este método será chamado após cada adição/atualização
  /// de um lançamento no BetJournal e usará o MetricsService para calcular.
  Future<void> updateMetrics({
    required double newTotalProfit,
    required double newRoi,
    required double newHitRate,
  }) async {
    // Simulação de delay para operação de cálculo
    await Future.delayed(const Duration(milliseconds: 400));
    
    // Cria um novo estado de métricas.
    _metrics = FinancialMetricsModel(
      totalProfit: newTotalProfit,
      roi: newRoi,
      hitRate: newHitRate,
    );

    // Notifica a UI para atualizar o Dashboard e outros indicadores.
    notifyListeners();
  }

  /// Método inicial para carregar as métricas ao iniciar o aplicativo.
  Future<void> loadInitialMetrics() async {
    // Simulação de carregamento do StorageService.
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Simulação de dados iniciais ou carregados
    _metrics = FinancialMetricsModel(
      totalProfit: 150.75,
      roi: 0.08,
      hitRate: 0.65,
    );
    
    notifyListeners();
  }
}