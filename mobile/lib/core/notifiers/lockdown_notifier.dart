import 'package:flutter/material.dart';
import 'package:antibet/src/core/services/lockdown_service.dart';
import 'package:antibet/src/core/notifiers/behavioral_analytics_notifier.dart';

// O Notifier é a camada de comunicação entre o Service (lógica) e a UI (apresentação).

class LockdownNotifier extends ChangeNotifier {
  final LockdownService _service;
  
  // Variável para armazenar o estado atual de forma reativa
  bool _isLockdownActive = false;
  
  // Late-Binding para Notifiers que precisam reagir ao Lockdown
  BehavioralAnalyticsNotifier? _analyticsNotifier;

  LockdownNotifier({required LockdownService service}) : _service = service {
    // Carrega o estado inicial do serviço de forma assíncrona
    checkLockdownStatus();
  }

  // Getter público para o estado
  bool get isLockdownActive => _isLockdownActive;
  
  // Setter para injeção de dependência cruzada após a inicialização (Late-Binding)
  void setAnalyticsNotifier(BehavioralAnalyticsNotifier notifier) {
    _analyticsNotifier = notifier;
  }

  /// Verifica o status atual do Lockdown no Service e atualiza o Notifier.
  Future<void> checkLockdownStatus() async {
    _isLockdownActive = await _service.isLockdownActive();
    // Notifica os ouvintes (ex: AppRouter e LockdownView) sobre a mudança de estado
    notifyListeners();
  }

  /// Aciona o modo de Pânico.
  Future<void> activateLockdown() async {
    try {
      await _service.activateLockdown();
      await checkLockdownStatus(); // Re-carrega o estado para confirmar a ativação
      
      // Opcional: notificar o Analytics sobre a intervenção de pânico
      _analyticsNotifier?.recordPanicIntervention();
      
    } catch (e) {
      // Log de erro
      print('Erro ao ativar Lockdown: $e');
    }
  }

  /// Desativa o modo de Pânico (só permitido após tempo mínimo de bloqueio).
  Future<bool> deactivateLockdown() async {
    try {
      await _service.deactivateLockdown();
      await checkLockdownStatus(); // Re-carrega o estado para confirmar a desativação
      return true;
    } catch (e) {
      // Exibir feedback de que o tempo mínimo não passou ou outro erro.
      print('Erro ao desativar Lockdown: $e');
      return false;
    }
  }

  // Future: Métodos para verificar o tempo restante, se aplicável na UI
  // Future<Duration> getRemainingTime() async { ... }
}