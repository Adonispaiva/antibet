import 'package:flutter/foundation.dart';
import 'package:antibet_app/infra/services/lockdown_service.dart';
import 'package:antibet_app/notifiers/behavioral_analytics_notifier.dart'; // Importação do Notifier de Risco

/// Gerencia o estado do bloqueio do usuário (Missão Anti-Vício).
///
/// Este Notifier é escutado pelo AppRouter para forçar o redirecionamento
/// para a tela de bloqueio (LockdownScreen).
class LockdownNotifier with ChangeNotifier {
  final LockdownService _lockdownService;

  // Estado
  bool _isInLockdown = false;
  DateTime? _lockdownEndTime;
  
  // Dependência Cruzada (Injetada no main.dart)
  BehavioralAnalyticsNotifier? _analyticsNotifier;

  // Getters (Leitura de Estado)
  bool get isInLockdown => _isInLockdown;
  DateTime? get lockdownEndTime => _lockdownEndTime;

  LockdownNotifier(this._lockdownService);

  /// Recebe a injeção do notificador de Analytics (Late Binding).
  void setAnalyticsNotifier(BehavioralAnalyticsNotifier notifier) {
    _analyticsNotifier = notifier;
    // Ouve o Analytics Notifier para reagir a mudanças de risco em tempo real
    _analyticsNotifier?.addListener(_handleRiskScoreUpdate);
  }
  
  // --- Lógica de Decisão de Bloqueio ---
  
  /// Lida com a mudança no Escore de Risco em tempo real.
  void _handleRiskScoreUpdate() async {
    // Apenas verifica se a mudanca de estado no Analytics requer bloqueio,
    // se o usuario nao estiver ja bloqueado.
    if (!_isInLockdown && _analyticsNotifier?.riskLevel == RiskLevel.high) {
      // Dispara o bloqueio preventivo (Lockdown Automatico)
      await _autoActivateLockdown(const Duration(hours: 1)); 
    }
  }
  
  /// Ativa o Botão de Pânico (Bloqueio manual).
  Future<void> activateLockdown() async {
    if (_isInLockdown) return;

    // 1. Ativa o bloqueio e salva o tempo (24h - Padrao de panico)
    final newEndTime = await _lockdownService.activateLockdown();
    
    _lockdownEndTime = newEndTime;
    _isInLockdown = true;
    
    // 2. Registra o evento no Analytics (Missão Anti-Vício)
    _analyticsNotifier?.trackEvent('lockdown_activated');
    
    // 3. Notifica o AppRouter e os Listeners da UI
    notifyListeners(); 
  }
  
  /// Ativa o bloqueio automaticamente (Ex: por alto risco).
  Future<void> _autoActivateLockdown(Duration duration) async {
    // Garante que o LockdownService pode persistir o tempo.
    final newEndTime = DateTime.now().add(duration);
    await _lockdownService.saveLockdownEndTime(newEndTime); 

    _lockdownEndTime = newEndTime;
    _isInLockdown = true;

    // Registra o evento de bloqueio automatico
    _analyticsNotifier?.trackEvent('lockdown_auto_triggered_high_risk');
    
    if (kDebugMode) {
      print("Lockdown AUTOMATICO ativado. Fim em: $_lockdownEndTime");
    }
    
    notifyListeners();
  }


  /// Carrega o status de bloqueio no início da aplicação.
  Future<bool> checkLockdownStatus() async {
    // 1. Verifica persistência local (Botão de Pânico ou Bloqueio Automático)
    final endTime = await _lockdownService.checkLockdownStatus();
    
    if (endTime != null) {
      _lockdownEndTime = endTime;
      _isInLockdown = true;
      return true;
    }
    
    // 2. Verifica regras de Risco (Se já estiver no nível de bloqueio, ativa o lockdown)
    if (_analyticsNotifier?.riskLevel == RiskLevel.high) {
      // Se a persistência falhou, mas o risco é alto, reativa o bloqueio temporário
      await _autoActivateLockdown(const Duration(hours: 1)); 
      return true; // O _autoActivateLockdown define o estado
    }
    
    // Limpa o estado se nenhuma regra for ativada
    _lockdownEndTime = null;
    _isInLockdown = false;
    
    return _isInLockdown;
  }
  
  /// Limpa o estado de bloqueio (para cancelamento administrativo)
  Future<void> clearLockdown() async {
    if (!_isInLockdown) return;
    
    await _lockdownService.clearLockdown();
    _lockdownEndTime = null;
    _isInLockdown = false;
    
    notifyListeners();
  }
  
  // (O dispose deve ser implementado para remover o listener do Analytics)
  @override
  void dispose() {
    _analyticsNotifier?.removeListener(_handleRiskScoreUpdate);
    super.dispose();
  }
}