import 'package:flutter/material.dart';
import 'package:antibet/src/core/services/open_banking_service.dart';

// Este Notifier gerencia o estado reativo da conexão Open Banking e as métricas financeiras.

class OpenBankingNotifier extends ChangeNotifier {
  final OpenBankingService _service;
  
  // Variáveis privadas para o estado
  bool _isConnected = false;
  bool _isLoading = false;
  double _accumulatedSavings = 0.0;
  double _totalLossesLast30Days = 0.0;

  OpenBankingNotifier(this._service);

  // Getters públicos para consumo pela UI
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  double get accumulatedSavings => _accumulatedSavings;
  double get totalLossesLast30Days => _totalLossesLast30Days;

  /// Inicia o fluxo de conexão do Open Banking.
  Future<bool> connectBank() async {
    _isLoading = true;
    notifyListeners();

    final success = await _service.connectToBank();
    _isConnected = success;

    if (success) {
      await fetchFinancialData(); // Busca os dados imediatamente após conectar
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  /// Finaliza a conexão do Open Banking.
  Future<void> disconnectBank() async {
    await _service.disconnectBank();
    _isConnected = false;
    _accumulatedSavings = 0.0;
    _totalLossesLast30Days = 0.0;
    notifyListeners();
  }

  /// Busca o Saldo AntiBet e as Perdas do Serviço.
  Future<void> fetchFinancialData() async {
    if (!_isConnected) return;
    
    _isLoading = true;
    notifyListeners();

    // Período de análise: Últimos 30 dias para as perdas
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));

    // Busca os dados simultaneamente
    final savingsFuture = _service.calculateAccumulatedSavings();
    final lossesFuture = _service.calculateTotalLosses(startDate, endDate);

    final results = await Future.wait([savingsFuture, lossesFuture]);
    
    _accumulatedSavings = results[0];
    _totalLossesLast30Days = results[1];

    _isLoading = false;
    notifyListeners();
    
    print('Dados Financeiros carregados. Economia: $_accumulatedSavings, Perdas 30d: $_totalLossesLast30Days');
  }
}