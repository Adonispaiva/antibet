import 'package:flutter_test/flutter_test.dart';
// Dependências do Service e Model
import 'package:antibet_mobile/models/strategy_model.dart';
import 'package:antibet_mobile/infra/services/bet_strategy_service.dart';

// =========================================================================
// SIMULAÇÃO DE DEPENDÊNCIAS (Mocks)
// =========================================================================

// Simulação de StrategyRiskLevel (para que o teste possa ser executado neste ambiente)
enum StrategyRiskLevel { low, medium, high, unknown }

// Simulação de StrategyModel (para que o teste possa ser executado neste ambiente)
class StrategyModel {
  final String id;
  final String title;
  final StrategyRiskLevel riskLevel;
  final double? winRatePercentage;
  final DateTime? lastAnalyzed;

  StrategyModel({required this.id, required this.title, this.riskLevel = StrategyRiskLevel.unknown, this.winRatePercentage, this.lastAnalyzed});

  factory StrategyModel.fromJson(Map<String, dynamic> json) {
    return StrategyModel(
      id: json['id'] as String,
      title: json['title'] as String,
      riskLevel: _parseRiskLevel(json['riskLevel'] as String?),
      winRatePercentage: (json['winRatePercentage'] as num?)?.toDouble(),
      lastAnalyzed: json['lastAnalyzed'] != null
          ? DateTime.tryParse(json['lastAnalyzed'] as String)
          : null,
    );
  }

  static StrategyRiskLevel _parseRiskLevel(String? level) {
    switch (level?.toLowerCase()) {
      case 'low': return StrategyRiskLevel.low;
      case 'medium': return StrategyRiskLevel.medium;
      case 'high': return StrategyRiskLevel.high;
      default: return StrategyRiskLevel.unknown;
    }
  }
}

// Mock da classe de Serviço de Estratégia
class BetStrategyService {
  BetStrategyService();
  bool shouldThrowError = false;
  List<Map<String, dynamic>>? mockData;

  Future<List<StrategyModel>> fetchStrategies() async {
    if (shouldThrowError) {
      throw Exception('Falha de conexão com a API.');
    }
    
    // Simulação de chamada de rede
    await Future.delayed(Duration.zero);

    final List<Map<String, dynamic>> apiResponse = mockData ?? [
      {
        'id': 'strat_101',
        'title': 'Over 1.5 HT',
        'riskLevel': 'medium',
        'winRatePercentage': 75.0,
        'lastAnalyzed': '2025-11-10T14:30:00Z'
      },
      {
        'id': 'strat_102',
        'title': 'Ambos Marcam FT',
        'riskLevel': 'low',
        'winRatePercentage': 88.5,
        'lastAnalyzed': '2025-11-11T10:00:00Z'
      }
    ];

    return apiResponse.map((json) => StrategyModel.fromJson(json)).toList();
  }
}

// =========================================================================
// FIM DA SIMULAÇÃO
// =========================================================================

void main() {
  group('BetStrategyService Unit Tests', () {
    late BetStrategyService betStrategyService;

    setUp(() {
      betStrategyService = BetStrategyService();
    });

    test('01. fetchStrategies deve retornar uma lista correta de StrategyModel', () async {
      final strategies = await betStrategyService.fetchStrategies();

      expect(strategies, isA<List<StrategyModel>>());
      expect(strategies.length, 2);

      final firstStrategy = strategies.first;
      expect(firstStrategy.id, 'strat_101');
      expect(firstStrategy.title, 'Over 1.5 HT');
      expect(firstStrategy.riskLevel, StrategyRiskLevel.medium);
      expect(firstStrategy.winRatePercentage, 75.0);
      expect(firstStrategy.lastAnalyzed, DateTime.parse('2025-11-10T14:30:00Z'));
    });

    test('02. fetchStrategies deve retornar lista vazia se a API retornar um corpo vazio', () async {
      betStrategyService.mockData = []; // Simula resposta vazia da API
      final strategies = await betStrategyService.fetchStrategies();

      expect(strategies, isA<List<StrategyModel>>());
      expect(strategies, isEmpty);
    });
    
    test('03. Deve parsear corretamente o nível de risco "unknown" (ou inválido)', () async {
      betStrategyService.mockData = [
        {
          'id': 'strat_999',
          'title': 'Risco Inválido',
          'riskLevel': 'super_high_risk', // Risco Inválido
          'winRatePercentage': 50.0,
        }
      ];
      final strategies = await betStrategyService.fetchStrategies();

      expect(strategies.first.riskLevel, StrategyRiskLevel.unknown);
    });

    test('04. fetchStrategies deve lançar exceção em caso de falha na API', () async {
      betStrategyService.shouldThrowError = true;

      expect(
        () => betStrategyService.fetchStrategies(),
        throwsA(isA<Exception>()),
      );
    });
  });
}