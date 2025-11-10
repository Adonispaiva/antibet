import 'dart:async';
import 'package:flutter/foundation.dart';

/// Define o serviço para rastrear o comportamento do usuário e calcular o Escore de Risco.
///
/// Este é o coração da Missão Anti-Vício, fornecendo a métrica que o LockdownNotifier
/// usará para decidir sobre o bloqueio preventivo.
class BehavioralAnalyticsService {
  
  // Onde o escore de risco é armazenado (simulando persistência ou backend)
  double _currentRiskScore = 0.0;
  
  // Mapeamento de eventos para pontuações de risco
  static const Map<String, double> _eventRiskMap = {
    'lockdown_activated': 100.0,   // Ativação do Botão de Pânico
    'bet_limit_exceeded': 50.0,    // Limite de aposta ultrapassado
    'high_frequency_bet': 20.0,    // Aposta em alta frequência
    'session_duration_alert': 15.0 // Sessão muito longa
  };
  
  BehavioralAnalyticsService();

  /// Carrega ou calcula o escore de risco atual do usuário.
  Future<double> calculateAnalytics() async {
    await Future.delayed(const Duration(milliseconds: 50)); // Simula latência
    
    // Simulação: Em produção, isso faria uma chamada ao Backend para buscar
    // o escore de risco atual baseado nos dados de perfil.
    // Por enquanto, retorna o score simulado.
    
    if (kDebugMode) {
      debugPrint("BehavioralAnalyticsService: Escore de Risco carregado: $_currentRiskScore");
    }
    
    return _currentRiskScore;
  }

  /// Registra um evento de comportamento de risco e recalcula o escore.
  Future<void> trackEvent(String eventName) async {
    final riskIncrease = _eventRiskMap[eventName] ?? 0.0;
    
    if (riskIncrease > 0) {
      _currentRiskScore += riskIncrease;
      
      // Simulação: Persistir o novo score (no storage ou backend)
      await Future.delayed(const Duration(milliseconds: 20)); 
      
      if (kDebugMode) {
        debugPrint("Evento registrado: $eventName. Novo Escore: $_currentRiskScore");
      }
    }
    // NOTA: O BehavioralAnalyticsNotifier sera responsavel por recalcular o estado
  }
  
  /// Obtém o escore de risco atual.
  double getCurrentRiskScore() {
    return _currentRiskScore;
  }
}