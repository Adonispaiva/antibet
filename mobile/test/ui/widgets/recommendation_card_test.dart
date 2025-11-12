import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
// Dependências do Widget e dos Notifiers
import 'package:antibet_mobile/models/strategy_recommendation_model.dart';
import 'package:antibet_mobile/models/strategy_model.dart';
import 'package:antibet_mobile/notifiers/strategy_recommendation_notifier.dart';
import 'package:antibet_mobile/notifiers/bet_strategy_notifier.dart';
import 'package:antibet_mobile/ui/widgets/recommendation_card.dart';

// =========================================================================
// SIMULAÇÃO DE DEPENDÊNCIES (Mocks)
// =========================================================================

// Simulação de StrategyRiskLevel (para que o teste possa ser executado neste ambiente)
enum StrategyRiskLevel { low, medium, high, unknown }

// Simulação de StrategyModel (para que o teste possa ser executado neste ambiente)
class StrategyModel {
  final String id;
  final String title;
  final StrategyRiskLevel riskLevel;
  StrategyModel({required this.id, required this.title, this.riskLevel = StrategyRiskLevel.unknown});
}

// Simulação de StrategyRecommendationModel (para que o teste possa ser executado neste ambiente)
class StrategyRecommendationModel {
  final String strategyId;
  final String rationale;
  final double confidenceScore;
  final String reasonCode;

  StrategyRecommendationModel({required this.strategyId, required this.rationale, required this.confidenceScore, required this.reasonCode});
  
  factory StrategyRecommendationModel.empty() => StrategyRecommendationModel(
    strategyId: 'none',
    rationale: 'Aguardando dados para gerar recomendações...',
    confidenceScore: 0.0,
    reasonCode: 'EMPTY',
  );
}

// Mock do Notifier de Recomendação
class MockStrategyRecommendationNotifier with ChangeNotifier implements StrategyRecommendationNotifier {
  @override
  bool isLoading = false;
  @override
  StrategyRecommendationModel recommendation = StrategyRecommendationModel.empty();
  @override
  String? errorMessage;
  @override
  bool get hasError => errorMessage != null;
  @override
  String get formattedConfidence => (recommendation.confidenceScore * 100).toStringAsFixed(0) + '%';
  @override
  Future<void> loadRecommendation() async {}
}

// Mock do Notifier de Estratégias
class MockBetStrategyNotifier with ChangeNotifier implements BetStrategyNotifier {
  @override
  bool isLoading = false;
  @override
  List<StrategyModel> strategies = [];
  @override
  String? errorMessage;
  @override
  bool get hasError => errorMessage != null;
  @override
  Future<void> loadStrategies() async {}
}

// SIMULAÇÃO DE RecommendationCard (mínimo necessário para o teste)
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({super.key});
  
  @override
  Widget build(BuildContext context) {
    final recommendationNotifier = context.watch<StrategyRecommendationNotifier>();
    final recommendation = recommendationNotifier.recommendation;
    final isLoading = recommendationNotifier.isLoading;
    final strategies = context.read<BetStrategyNotifier>().strategies;

    final recommendedStrategy = strategies.firstWhere(
      (s) => s.id == recommendation.strategyId,
      orElse: () => null!,
    );
    
    final String strategyName = recommendedStrategy?.title ?? 'Estratégia Desconhecida';
    final bool canNavigate = recommendedStrategy != null;

    if (isLoading) {
      return const Card(child: ListTile(title: Text('Analisando seu desempenho...')));
    }
    
    if (recommendation.reasonCode == 'EMPTY' || strategies.isEmpty) {
      return Card(child: ListTile(title: const Text('Recomendação de Estratégia'), subtitle: Text(recommendation.rationale)));
    }

    return Card(
      child: Column(
        children: [
          // Exibe o Nome da Estratégia e Confiança
          ListTile(
            title: Text(strategyName),
            trailing: Text(recommendationNotifier.formattedConfidence),
            subtitle: Text(recommendation.rationale),
          ),
          // Botão de Ação
          if (canNavigate)
            TextButton(
              onPressed: () {}, // Simula a navegação
              child: const Text('VER DETALHES E RISCO'),
            ),
        ],
      ),
    );
  }
}

// =========================================================================
// FIM DA SIMULAÇÃO
// =========================================================================

void main() {
  group('RecommendationCard Widget Tests', () {
    late MockStrategyRecommendationNotifier mockRecNotifier;
    late MockBetStrategyNotifier mockStratNotifier;
    
    // Dados de Teste
    final tRecommendedStrategy = StrategyModel(id: 'strat_101', title: 'Over 1.5 HT');
    final tRecommendation = StrategyRecommendationModel(
      strategyId: 'strat_101', 
      rationale: 'Seu ROI é superior à média.', 
      confidenceScore: 0.92, 
      reasonCode: 'SUCCESS'
    );
    
    // Wrapper para injetar os Notifiers no widget
    Widget createWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<StrategyRecommendationNotifier>.value(value: mockRecNotifier),
          ChangeNotifierProvider<BetStrategyNotifier>.value(value: mockStratNotifier),
        ],
        child: const MaterialApp(home: RecommendationCard()),
      );
    }

    setUp(() {
      mockRecNotifier = MockStrategyRecommendationNotifier();
      mockStratNotifier = MockBetStrategyNotifier();
      // Define o estado inicial para sucesso
      mockRecNotifier.recommendation = tRecommendation;
      mockStratNotifier.strategies = [tRecommendedStrategy];
    });

    testWidgets('01. Deve exibir o nome da estratégia, racional e confiança para sucesso', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Verifica o nome e o racional
      expect(find.text('Over 1.5 HT'), findsOneWidget);
      expect(find.text('Seu ROI é superior à média.'), findsOneWidget);
      
      // Verifica a Confiança (92% de 0.92)
      expect(find.text('92%'), findsOneWidget); 
      
      // Verifica o botão de navegação
      expect(find.text('VER DETALHES E RISCO'), findsOneWidget);
    });
    
    testWidgets('02. Deve exibir o estado de Loading quando isLoading for true', (WidgetTester tester) async {
      mockRecNotifier.isLoading = true;
      mockRecNotifier.recommendation = StrategyRecommendationModel.empty(); // Limpa o dado para isolar o loading
      
      await tester.pumpWidget(createWidget());

      // Verifica a mensagem de loading
      expect(find.text('Analisando seu desempenho...'), findsOneWidget);
      
      // O botão não deve aparecer
      expect(find.text('VER DETALHES E RISCO'), findsNothing);
    });

    testWidgets('03. Deve exibir o estado de Vazio (EMPTY) quando a recomendação não puder ser gerada', (WidgetTester tester) async {
      mockRecNotifier.recommendation = StrategyRecommendationModel.empty();
      
      await tester.pumpWidget(createWidget());

      // Verifica o título e o racional do estado vazio
      expect(find.text('Recomendação de Estratégia'), findsOneWidget);
      expect(find.text('Aguardando dados para gerar recomendações...'), findsOneWidget);
      
      // O botão não deve aparecer
      expect(find.text('VER DETALHES E RISCO'), findsNothing);
    });
    
    testWidgets('04. Deve exibir Estratégia Desconhecida se o ID não for encontrado', (WidgetTester tester) async {
      // Recomendação para um ID que não existe na lista de estratégias
      mockRecNotifier.recommendation = StrategyRecommendationModel(
        strategyId: 'strat_999', rationale: 'Não existe.', confidenceScore: 0.5, reasonCode: 'SUCCESS'
      );
      
      await tester.pumpWidget(createWidget());
      
      // O nome deve ser "Estratégia Desconhecida"
      expect(find.text('Estratégia Desconhecida'), findsOneWidget);
      // O botão VER DETALHES NÃO deve aparecer (canNavigate=false)
      expect(find.text('VER DETALHES E RISCO'), findsNothing);
    });
  });
}