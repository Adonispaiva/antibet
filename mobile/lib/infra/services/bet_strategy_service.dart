import 'dart:async';

// Placeholder temporário para o modelo de Estratégia de Aposta
// Este modelo deve ser definido em 'mobile/lib/domain/models/bet_strategy_model.dart' futuramente.
class BetStrategyModel {
  final String id;
  final String name;
  final String description;
  final double successRate;

  BetStrategyModel({
    required this.id,
    required this.name,
    required this.description,
    required this.successRate,
  });
  
  // Placeholder para desserialização
  factory BetStrategyModel.fromJson(Map<String, dynamic> json) {
    return BetStrategyModel(
      id: json['id'] ?? 'strategy_default',
      name: json['name'] ?? 'Estratégia Padrão',
      description: json['description'] ?? 'Estratégia básica de baixo risco.',
      successRate: json['successRate'] ?? 0.0,
    );
  }
}

// O BetStrategyService é responsável por buscar e gerenciar as estratégias de aposta
// fornecidas pelo sistema para análise do usuário.
class BetStrategyService {
  
  // Construtor
  BetStrategyService();

  // 1. Simulação da chamada de API para buscar a lista de estratégias disponíveis
  Future<List<BetStrategyModel>> fetchAvailableStrategies() async {
    // -----------------------------------------------------------------
    // TODO: Implementar a chamada HTTP real (GET /strategies/available)
    // -----------------------------------------------------------------

    // Simulação de delay de rede
    await Future.delayed(const Duration(milliseconds: 600));

    // Simulação de uma lista de estratégias
    return [
      BetStrategyModel(
        id: 's-v1',
        name: 'AntiBet Clássico',
        description: 'Foco em análise de risco e probabilidade.',
        successRate: 0.82,
      ),
      BetStrategyModel(
        id: 's-v2',
        name: 'Detector-Pro',
        description: 'Estratégia de alta frequência com foco em volume.',
        successRate: 0.75,
      ),
      BetStrategyModel(
        id: 's-v3',
        name: 'Maratona Segura',
        description: 'Estratégia de longo prazo para crescimento lento.',
        successRate: 0.91,
      ),
    ];
  }

  // 2. Simulação da chamada para buscar detalhes de uma estratégia específica
  Future<BetStrategyModel?> fetchStrategyDetails(String strategyId) async {
     // -----------------------------------------------------------------
    // TODO: Implementar a chamada HTTP real (GET /strategies/{id})
    // -----------------------------------------------------------------
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Simulação de detalhes para uma estratégia
    return BetStrategyModel(
      id: strategyId,
      name: 'AntiBet Clássico',
      description: 'Análise detalhada do fluxo de caixa e risco. Recomendado para iniciantes.',
      successRate: 0.82,
    );
  }
}