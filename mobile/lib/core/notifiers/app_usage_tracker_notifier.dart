import 'package:flutter/material.dart';
import 'package:antibet/src/core/services/app_usage_tracker_service.dart';

// Este Notifier gerencia o estado reativo dos dados de uso de aplicativos
// e fornece estas métricas em tempo real para o módulo de BehavioralAnalytics.

class AppUsageTrackerNotifier extends ChangeNotifier {
  final AppUsageTrackerService _service;
  
  List<AppUsageData> _recentUsageData = [];
  bool _hasPermission = false;
  bool _isLoading = false;

  AppUsageTrackerNotifier(this._service) {
    checkPermissionStatus();
  }

  // Getters públicos
  List<AppUsageData> get recentUsageData => List.unmodifiable(_recentUsageData);
  bool get hasPermission => _hasPermission;
  bool get isLoading => _isLoading;
  
  // Métrica Chave: Total de tempo gasto em apps de alto risco nas últimas 24h
  Duration get totalHighRiskTime {
    return _recentUsageData
        .where((data) => data.isHighRisk)
        .fold(Duration.zero, (sum, data) => sum + data.timeSpent);
  }

  /// Verifica e atualiza o estado da permissão de acesso ao uso.
  Future<void> checkPermissionStatus() async {
    _hasPermission = await _service.checkUsagePermission();
    notifyListeners();
    if (_hasPermission) {
      // Se a permissão estiver ok, tenta buscar os dados iniciais
      await fetchUsageDataForAnalytics();
    }
  }

  /// Solicita as permissões, abrindo a tela de configurações nativa.
  Future<void> requestPermission() async {
    await _service.requestUsagePermission();
    // Nota: O usuário deve retornar ao app, e o estado será verificado novamente.
    // Em produção, isso seria acompanhado de um listener de foco.
    await Future.delayed(const Duration(seconds: 3)); 
    await checkPermissionStatus();
  }

  /// Busca os dados de uso para o período de análise (últimas 24h).
  Future<void> fetchUsageDataForAnalytics() async {
    if (!_hasPermission) return;
    
    _isLoading = true;
    notifyListeners();

    final end = DateTime.now();
    final start = end.subtract(const Duration(hours: 24)); // Últimas 24h para análise

    final data = await _service.getUsageData(start, end);
    
    _recentUsageData = data;
    _isLoading = false;
    notifyListeners();
    
    print('Dados de uso carregados. Tempo total de risco: ${totalHighRiskTime.inMinutes} minutos.');
  }
}