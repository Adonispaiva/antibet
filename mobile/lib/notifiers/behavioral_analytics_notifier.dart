import 'package:flutter/foundation.dart';
import 'package:antibet_app/infra/services/behavioral_analytics_service.dart';

/// Define o nível de risco do usuário com base no escore.
enum RiskLevel { 
  low,      // 0.0 - 49.9
  medium,   // 50.0 - 99.9
  high,     // 100.0 ou mais
}

/// Gerencia o estado do Escore de Risco Comportamental (Missão Anti-Vício).
///
/// Este Notifier é consumido por toda a aplicação e é crucial para a lógica
/// de bloqueio do LockdownNotifier.
class BehavioralAnalyticsNotifier with ChangeNotifier {
  final BehavioralAnalyticsService _analyticsService;

  // Estado
  double _riskScore = 0.0;
  
  // Limites de Risco
  static const double _highRiskThreshold = 100.0;
  static const double _mediumRiskThreshold = 50.0;

  // Getters (Leitura de Estado)
  double get riskScore => _riskScore;
  
  RiskLevel get riskLevel {
    if (_riskScore >= _highRiskThreshold) {
      return RiskLevel.high;
    } else if (_riskScore >= _mediumRiskThreshold) {
      return RiskLevel.medium;
    } else {
      return RiskLevel.low;
    }
  }

  BehavioralAnalyticsNotifier(this._analyticsService);

  /// Carrega o estado inicial do escore de risco na inicialização da aplicação.
  Future<void> calculateAnalytics() async {
    _riskScore = await _analyticsService.calculateAnalytics();
    
    if (kDebugMode) {
      debugPrint("Analytics carregado. Escore: $_riskScore. Nível: ${riskLevel.name}");
    }
    
    // O notifyListeners não é estritamente necessário no startup.
  }

  /// Registra um evento de risco e atualiza o estado.
  Future<void> trackEvent(String eventName) async {
    // 1. O serviço registra o evento e persiste o novo escore.
    await _analyticsService.trackEvent(eventName);
    
    // 2. O Notifier busca o novo escore do serviço (ou o serviço poderia retornar o novo escore).
    _riskScore = _analyticsService.getCurrentRiskScore();
    
    if (kDebugMode) {
      debugPrint("Evento $eventName registrado. Novo Escore: $_riskScore");
    }
    
    // 3. Notifica todos os ouvintes (incluindo o LockdownNotifier e UI).
    notifyListeners();
  }
}