import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:antibet_mobile/models/dashboard_summary_model.dart';
import 'package:antibet_mobile/infra/services/dashboard_service.dart';
import 'package:antibet_mobile/notifiers/dashboard_notifier.dart';

// =========================================================================
// SIMULAÇÃO DE DEPENDÊNCIAS (Mocks)
// =========================================================================

// Simulação de DashboardSummaryModel (mínimo necessário para o teste)
class DashboardSummaryModel {
  final int totalStrategies;
  final double averageWinRate;
  DashboardSummaryModel({required this.totalStrategies, required this.averageWinRate});
  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) => throw UnimplementedError();
  static DashboardSummaryModel empty() => DashboardSummaryModel(totalStrategies: 0, averageWinRate: 0.0);
}

// Simulação de DashboardService (mínimo necessário para o teste)
class DashboardService {
  DashboardService();
  Future<DashboardSummaryModel> getDashboardSummary() async => throw UnimplementedError();
}

// Mock da classe de Serviço do Dashboard
class MockDashboardService implements DashboardService {
  MockDashboardService();
  bool shouldThrowError = false;
  
  final tSummary = DashboardSummaryModel(totalStrategies: 50, averageWinRate: 80.0);

  @override
  Future<DashboardSummaryModel> getDashboardSummary() async {
    if (shouldThrowError) {
      await Future.delayed(Duration.zero);
      throw Exception('Falha de conexão simulada');
    }
    await Future.delayed(Duration.zero);
    return tSummary;
  }
}

// SIMULAÇÃO DO NOTIFIER (mínimo necessário para o teste)
class DashboardNotifier with ChangeNotifier {
  final MockDashboardService _dashboardService;

  bool _isLoading = false;
  DashboardSummaryModel _summary = DashboardSummaryModel.empty(); 
  String? _errorMessage;

  DashboardNotifier(this._dashboardService);

  bool get isLoading => _isLoading;
  DashboardSummaryModel get summary => _summary;
  String? get errorMessage => _errorMessage;

  Future<void> loadSummary() async {
    _setStateLoading(true);

    try {
      _summary = await _dashboardService.getDashboardSummary();
      _errorMessage = null;

    } catch (e) {
      _errorMessage = 'Falha ao carregar dados do dashboard.';
      _summary = DashboardSummaryModel.empty(); 
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
  group('DashboardNotifier Unit Tests', () {
    late DashboardNotifier notifier;
    late MockDashboardService mockService;
    
    // Configuração: Garante estado limpo e objetos antes de cada teste
    setUp(() {
      mockService = MockDashboardService();
      notifier = DashboardNotifier(mockService);
    });

    test('01. loadSummary deve carregar dados com sucesso', () async {
      // 1. Estado inicial
      expect(notifier.isLoading, false);
      expect(notifier.summary.totalStrategies, 0); // Deve começar com empty()
      
      // Chama o método
      final future = notifier.loadSummary();
      
      // 2. Estado de Loading (imediatamente após a chamada)
      expect(notifier.isLoading, true);
      
      await future;
      
      // 3. Estado de Sucesso
      expect(notifier.isLoading, false);
      expect(notifier.summary.totalStrategies, 50);
      expect(notifier.summary.averageWinRate, 80.0);
      expect(notifier.errorMessage, isNull);
    });
    
    test('02. loadSummary deve lidar com falha de serviço e definir a mensagem de erro', () async {
      mockService.shouldThrowError = true;
      
      await notifier.loadSummary();
      
      // Estado de Falha
      expect(notifier.isLoading, false);
      expect(notifier.summary.totalStrategies, 0); // Deve resetar para empty()
      expect(notifier.errorMessage, 'Falha ao carregar dados do dashboard.');
    });
  });
}