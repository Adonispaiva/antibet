// mobile/lib/core/services/metrics_service.dart

import 'package:antibet/core/services/journal_service.dart';
import 'package:antibet/features/journal/models/journal_entry_model.dart';
import 'package:antibet/features/metrics/models/metric_summary_model.dart';

/// Onde 1.0 representa 100%, 0.5 representa 50%, etc.
typedef MetricValue = double;

/// Serviço responsável por calcular métricas de performance do usuário.
/// 
/// Na Fase 3, substitui a simulação por cálculos reais baseados nas
/// entradas do JournalService (que usa persistência local).
class MetricsService {
  final JournalService _journalService;

  MetricsService(this._journalService);

  /// Carrega e calcula todas as métricas necessárias para a tela de Resumo.
  Future<List<MetricSummaryModel>> loadAllMetrics() async {
    // 1. Carrega todas as entradas do diário para o cálculo.
    final List<JournalEntryModel> allEntries = await _journalService.loadEntries();

    // 2. Cria e retorna a lista de métricas calculadas.
    return [
      _calculateReturnMetric(allEntries),
      _calculateWinRateMetric(allEntries),
      _calculateUsageRateMetric(allEntries),
    ];
  }

  /// Calcula o Retorno Total (ROI ou P&L).
  /// Exibe o valor absoluto e a porcentagem.
  MetricSummaryModel _calculateReturnMetric(List<JournalEntryModel> entries) {
    if (entries.isEmpty) {
      return MetricSummaryModel.empty('Retorno Total', isMonetary: true);
    }

    final double totalProfitLoss = entries.fold(
      0.0,
      (sum, entry) => sum + (entry.finalResult ?? 0.0),
    );

    // Simplificando o cálculo do ROI: Retorno Absoluto é a principal métrica
    // Em produção, o ROI % seria (Retorno / Capital Investido) * 100, 
    // mas para a v1.0, focamos no resultado absoluto (Lucro/Prejuízo).
    final MetricValue percentage = 0.0; // Não aplicável/calculado na v1.0
    final String absoluteValue = totalProfitLoss.toStringAsFixed(2);
    
    return MetricSummaryModel(
      title: 'Retorno Total',
      absoluteValue: absoluteValue,
      percentageChange: percentage,
      isPositive: totalProfitLoss >= 0,
      isMonetary: true,
    );
  }

  /// Calcula o Win Rate (Taxa de Acerto/Sucesso).
  /// (Ganhos / Total de Entradas)
  MetricSummaryModel _calculateWinRateMetric(List<JournalEntryModel> entries) {
    if (entries.isEmpty) {
      return MetricSummaryModel.empty('Win Rate', isMonetary: false);
    }

    final int totalEntries = entries.length;
    final int winningEntries = entries.where((e) => (e.finalResult ?? 0.0) > 0).length;

    final MetricValue winRate = totalEntries > 0 ? winningEntries / totalEntries : 0.0;

    return MetricSummaryModel(
      title: 'Win Rate',
      absoluteValue: '${(winRate * 100).toStringAsFixed(1)}%',
      percentageChange: winRate,
      isPositive: winRate >= 0.5, // 50% é o benchmark para "positivo"
      isMonetary: false,
    );
  }

  /// Calcula a Taxa de Utilização (Número de registros feitos).
  /// Simplesmente a contagem de entradas.
  MetricSummaryModel _calculateUsageRateMetric(List<JournalEntryModel> entries) {
    final int totalEntries = entries.length;

    // A Taxa de Utilização é um indicador de engajamento, não tem percentual de "mudança"
    // ou "positividade" intrínseco, exceto a contagem.
    final MetricValue percentage = 0.0; 
    
    return MetricSummaryModel(
      title: 'Registros',
      absoluteValue: totalEntries.toString(),
      percentageChange: percentage,
      isPositive: totalEntries > 0,
      isMonetary: false,
    );
  }
}