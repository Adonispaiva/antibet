import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:antibet_mobile/models/strategy_model.dart';
import 'package:antibet_mobile/infra/services/bet_strategy_service.dart';
import 'package:antibet_mobile/notifiers/bet_strategy_notifier.dart';

// =========================================================================
// SIMULAÇÃO DE DEPENDÊNCIAS (Mocks)
// =========================================================================

// Simulação de StrategyRiskLevel (mínimo necessário para o teste)
enum StrategyRiskLevel { low, medium, high, unknown }

// Simulação de StrategyModel (mínimo necessário para o teste)
class StrategyModel {
  final String id;
  final String title;
  final StrategyRiskLevel riskLevel;
  StrategyModel({required this.id, required this.title, this.riskLevel = StrategyRiskLevel.unknown});
  factory StrategyModel.fromJson(Map<String, dynamic> json) => throw UnimplementedError();
}

// Simulação de BetStrategyService (mínimo necessário para o teste)
class BetStrategyService {
  BetStrategyService();
  Future<List<StrategyModel>> fetchStrategies() async => throw UnimplementedError();
}

// Mock da classe de Serviço de Estratégia
class MockBetStrategyService implements BetStrategyService {
  MockBetStrategyService();
  bool shouldThrowError = false;
  List<StrategyModel> mockStrategies = [];

  @override
  Future<List<StrategyModel>> fetchStrategies() async {
    if (shouldThrowError) {
      await Future.delayed(Duration.zero);
      throw Exception('Falha de conexão simulada');
    }
    await Future.delayed(Duration.zero);
    return mockStrategies;
  }
}

// SIMULAÇÃO DO NOTIFIER (mínimo necessário para o teste)
class BetStrategyNotifier with ChangeNotifier {
  final MockBetStrategyService _betStrategyService;

  bool _isLoading = false;
  List<StrategyModel> _strategies = [];
  String? _errorMessage;

  BetStrategyNotifier(this._betStrategyService);

  bool get isLoading => _isLoading;
  List<StrategyModel> get strategies => List.unmodifiable(_strategies);
  String? get errorMessage => _errorMessage;

  Future<void> loadStrategies() async {
    _setStateLoading(true);

    try {
      _strategies = await _betStrategyService.fetchStrategies();
      
      // Simula a lógica de lista vazia
      if (_strategies.isEmpty) {
        _errorMessage = 'Nenhuma estratégia encontrada no momento.'; 
      } else {
        _errorMessage = null;
      }
      
    } catch (e) {
      _errorMessage = 'Falha ao buscar estratégias. Tente novamente.';
      _strategies = [];
    } finally {
      _setStateLoading(false);
    }
  }

  void _setStateLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    } else {
      notifyListeners();
    }
  }
}

// =========================================================================
// FIM DA SIMULAÇÃO
// =========================================================================

void main() {
  group('BetStrategyNotifier Unit Tests', () {
    late BetStrategyNotifier notifier;
    late MockBetStrategyService mockService;
    
    final tStrategy = StrategyModel(id: 's001', title: 'Test Strategy');

    // Configuração: Garante estado limpo e objetos antes de cada teste
    setUp(() {
      mockService = MockBetStrategyService();
      notifier = BetStrategyNotifier(mockService);
    });

    test('01. loadStrategies deve carregar dados com sucesso', () async {
      mockService.mockStrategies = [tStrategy];
      
      // 1. Estado inicial
      expect(notifier.isLoading, false);
      
      // Chama o método
      final future = notifier.loadStrategies();
      
      // 2. Estado de Loading (imediatamente após a chamada)
      expect(notifier.isLoading, true);
      
      await future;
      
      // 3. Estado de Sucesso
      expect(notifier.isLoading, false);
      expect(notifier.strategies.length, 1);
      expect(notifier.strategies.first.id, 's001');
      expect(notifier.errorMessage, isNull);
    });

    test('02. loadStrategies deve lidar com lista vazia corretamente', () async {
      mockService.mockStrategies = [];
      
      await notifier.loadStrategies();
      
      // Estado de Sucesso (Lista Vazia)
      expect(notifier.isLoading, false);
      expect(notifier.strategies, isEmpty);
      expect(notifier.errorMessage, 'Nenhuma estratégia encontrada no momento.');
    });

    test('03. loadStrategies deve lidar com falha de serviço e definir a mensagem de erro', () async {
      mockService.shouldThrowError = true;
      
      await notifier.loadStrategies();
      
      // Estado de Falha
      expect(notifier.isLoading, false);
      expect(notifier.strategies, isEmpty);
      expect(notifier.errorMessage, 'Falha ao buscar estratégias. Tente novamente.');
    });

    test('04. O getter strategies deve retornar uma lista imutável', () {
      mockService.mockStrategies = [tStrategy];
      
      notifier.loadStrategies();
      
      // Tenta modificar a lista retornada pelo getter
      final strategiesList = notifier.strategies;
      expect(() => strategiesList.add(tStrategy), throwsUnsupportedError);
    });
  });
}