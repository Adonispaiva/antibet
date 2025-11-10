import 'package:flutter/material.dart';
import 'package:antibet/src/core/services/behavioral_analytics_service.dart';
import 'package:antibet/src/core/notifiers/lockdown_notifier.dart'; // Dependência
import 'package:antibet/src/core/notifiers/app_usage_tracker_notifier.dart'; // NOVA DEPENDÊNCIA

// O Notifier gerencia o estado reativo do Escore de Risco Comportamental (Métrica Chave).

class BehavioralAnalyticsNotifier extends ChangeNotifier {
  final BehavioralAnalyticsService _service;
  final LockdownNotifier _lockdownNotifier;
  final AppUsageTrackerNotifier _appUsageNotifier; // INJEÇÃO DA NOVA DEPENDÊNCIA
  
  // Variáveis privadas para o estado
  double _riskScore = 0.0;
  bool _isHighRisk = false;
  
  // Intervalo de tempo para análise comportamental (ex: 7 dias em milissegundos)
  static const int _analysisWindow = 7 * 24 * 60 * 60 * 1000;

  BehavioralAnalyticsNotifier(this._service, this._lockdownNotifier, this._appUsageNotifier) {
    // Escuta mudanças no modo de pânico (Lockdown) para recalcular o risco
    _lockdownNotifier.addListener(calculateRiskScore);
    // Escuta mudanças nos dados de uso de apps
    _appUsageNotifier.addListener(calculateRiskScore); 
    
    // Inicia a primeira rodada de cálculo
    calculateRiskScore();
  }

  // Getters públicos
  double get riskScore => _riskScore;
  bool get isHighRisk => _isHighRisk;

  /// Registra um evento comportamental via Service.
  Future<void> recordBehavioralEvent(String eventType, [Map<String, dynamic>? details]) async {
    await _service.recordEvent(eventType, details);
    // Recalcula o risco após cada evento significativo
    await calculateRiskScore();
  }

  /// Calcula o Escore de Risco Comportamental (0.0 a 1.0)
  /// Incorpora dados de eventos, frequência de login, e agora, tempo de tela em risco.
  Future<void> calculateRiskScore() async {
    // 1. Busca os dados brutos de eventos no serviço
    final events = await _service.getRecentEvents(
      DateTime.now().subtract(const Duration(milliseconds: _analysisWindow)),
      DateTime.now(),
    );
    
    // 2. BUSCA DA NOVA MÉTRICA NATIVA (Tempo de Risco)
    final Duration highRiskTime = _appUsageNotifier.totalHighRiskTime; 
    
    // 3. Calcula Fatores de Risco
    
    // Fator A: Frequência de Login/Atividade
    final loginCount = events.where((e) => e.eventType == 'login_successful').length;
    final loginFactor = (loginCount / 20.0).clamp(0.0, 0.5); // Max 0.5 (se logar 20 vezes em 7 dias)
    
    // Fator B: Frequência de Recaídas/Crises (Uso do botão 'Quero Apostar')
    final crisisCount = events.where((e) => e.eventType == 'crisis_urge').length;
    final crisisFactor = (crisisCount / 10.0).clamp(0.0, 0.5); // Max 0.5 (se tiver 10 crises em 7 dias)

    // Fator C: PONDERADOR NATIVO (Tempo de Uso em Apps de Alto Risco)
    // 1 hora (60 min) de risco = 0.1 de fator
    final timeRiskFactor = (highRiskTime.inMinutes / 600.0).clamp(0.0, 0.5); // Max 0.5 (se usar 10 horas de risco em 24h)
    
    // 4. Escore Total (Ponderação: 40% Fator Crise, 30% Fator Login, 30% Fator Tempo)
    // A soma dos pesos pode ultrapassar 1.0, clampando o resultado final
    final rawScore = 
      (crisisFactor * 0.4) + 
      (loginFactor * 0.3) + 
      (timeRiskFactor * 0.3);

    // 5. Ajuste Final e Determinação do Alerta
    _riskScore = rawScore.clamp(0.0, 1.0);
    // Threshold de Risco Alto: 0.70 (definido nas constantes)
    _isHighRisk = _riskScore >= 0.70;

    // 6. Notificação
    notifyListeners();
    print('Escore de Risco recalculado: $_riskScore. Risco Alto: $_isHighRisk');
  }
}