import 'package:antibet_mobile/models/strategy_recommendation_model.dart';
import 'package:flutter/material.dart';

/// Camada de Serviço de Infraestrutura para o Motor de Recomendação de Estratégias.
///
/// Responsável por comunicar-se com o backend ou motor de IA/Análise de Dados
/// para obter a melhor sugestão de estratégia com base no perfil do usuário.
class StrategyRecommendationService {
  
  // Opcional: Este serviço dependeria de um ApiClient para se comunicar com o motor de IA.
  // final ApiClient _apiClient;
  // StrategyRecommendationService(this._apiClient);

  StrategyRecommendationService();

  /// Simula a obtenção da recomendação de estratégia mais adequada para o usuário.
  /// 
  /// O processo levaria em conta o histórico de apostas, risco preferencial
  /// e o desempenho atual de todas as estratégias disponíveis.
  Future<StrategyRecommendationModel> getRecommendation() async {
    try {
      debugPrint('[RecommendationService] Buscando recomendação do motor de IA...');
      await Future.delayed(const Duration(milliseconds: 900)); // Simulação de processamento de IA

      // --- SIMULAÇÃO DE RESPOSTA DO MOTOR DE IA ---
      // Cenário: O usuário tem bom desempenho em estratégias de baixo risco (strat_456)
      final Map<String, dynamic> mockApiResponse = {
        'strategyId': 'strat_456', // ID da estratégia "Empate Anula" (exemplo)
        'rationale': 'Seu ROI é 15% superior à média em estratégias de baixo risco. Sugerimos focar na "Empate Anula" para consolidação de ganhos.',
        'confidenceScore': 0.85,
        'reasonCode': 'ROI_LOW_RISK_FOCUS',
      };

      final recommendation = StrategyRecommendationModel.fromJson(mockApiResponse);

      debugPrint('[RecommendationService] Recomendação gerada com sucesso.');
      return recommendation;

    } catch (e) {
      debugPrint('[RecommendationService] Erro na obtenção de recomendação: $e');
      throw Exception('Falha ao gerar recomendação de estratégia.');
    }
  }

  /// Simulação de um cenário onde o backend retorna uma recomendação vazia (poucos dados).
  Future<StrategyRecommendationModel> getNoDataRecommendation() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return StrategyRecommendationModel.empty();
  }
}