import 'package:antibet_mobile/infra/services/strategy_recommendation_service.dart';
import 'package:antibet_mobile/models/strategy_recommendation_model.dart';
import 'package:flutter/material.dart';

/// Gerencia o estado e a lógica de negócios para a Recomendação de Estratégias.
///
/// Este Notifier utiliza o [StrategyRecommendationService] para obter sugestões
/// personalizadas do motor de IA e expor o resultado à UI.
class StrategyRecommendationNotifier with ChangeNotifier {
  final StrategyRecommendationService _recommendationService;

  bool _isLoading = false;
  StrategyRecommendationModel _recommendation = StrategyRecommendationModel.empty(); // Tipado e inicializado
  String? _errorMessage;

  // Construtor com injeção de dependência
  StrategyRecommendationNotifier(this._recommendationService) {
    // Carrega a recomendação inicial
    loadRecommendation();
  }

  // Getters públicos
  bool get isLoading => _isLoading;
  StrategyRecommendationModel get recommendation => _recommendation;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  
  // Getter derivado para facilitar a UI
  String get formattedConfidence => (_recommendation.confidenceScore * 100).toStringAsFixed(0) + '%';


  /// Dispara a obtenção da recomendação de estratégia.
  /// 
  /// Este método deve ser chamado sempre que o histórico de apostas (Journal)
  /// for alterado para garantir uma nova sugestão.
  Future<void> loadRecommendation() async {
    _setStateLoading(true);

    try {
      // Chama o serviço para obter a recomendação
      _recommendation = await _recommendationService.getRecommendation();
      _errorMessage = null;
      
    } catch (e) {
      // TODO: Implementar logging de erro robusto.
      debugPrint('[RecommendationNotifier] Erro ao carregar recomendação: $e');
      _errorMessage = 'Falha ao obter recomendação. Verifique seus dados.';
      _recommendation = StrategyRecommendationModel.empty(); // Limpa dados em caso de erro
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