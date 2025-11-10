import 'package:shared_preferences/shared_preferences.dart';

// Este serviço contém a lógica de negócio do Módulo de Pânico.
// Ele é o único responsável por alterar o estado de Lockdown de forma persistente.

class LockdownService {
  // Chave de persistência para o estado do Lockdown
  static const String _lockdownKey = 'isLockdownActive';

  // Chave para a data/hora de ativação (opcional para tempos de expiração)
  static const String _activationTimeKey = 'lockdownActivationTime';

  // Tempo mínimo de permanência no lockdown (ex: 24 horas)
  static const Duration MIN_LOCKDOWN_DURATION = Duration(hours: 24);

  // Armazena a referência às SharedPreferences
  late final SharedPreferences _prefs;

  // Construtor privado para inicialização assíncrona
  LockdownService() {
    _initPrefs();
  }

  // Inicializa as SharedPreferences
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Verifica se o Lockdown está ativo.
  Future<bool> isLockdownActive() async {
    await _initPrefs();
    final isActive = _prefs.getBool(_lockdownKey) ?? false;
    
    if (isActive) {
      // Lógica de expiração: verifica se o tempo mínimo já passou.
      final activationTimeMillis = _prefs.getInt(_activationTimeKey);
      if (activationTimeMillis != null) {
        final activationTime = DateTime.fromMillisecondsSinceEpoch(activationTimeMillis);
        final expiryTime = activationTime.add(MIN_LOCKDOWN_DURATION);
        
        if (DateTime.now().isBefore(expiryTime)) {
          // Ainda dentro do período de bloqueio forçado
          return true;
        } else {
          // O tempo expirou, permite que o usuário desative (soft-lock).
          return _prefs.getBool(_lockdownKey) ?? true; // Mantém ativo até desativação manual
        }
      }
    }
    return isActive;
  }

  /// Ativa o modo de Pânico.
  Future<void> activateLockdown() async {
    await _initPrefs();
    await _prefs.setBool(_lockdownKey, true);
    await _prefs.setInt(_activationTimeKey, DateTime.now().millisecondsSinceEpoch);
    // Em uma aplicação real, aqui haveria um evento de log/telemetria de alta severidade.
    print('Lockdown Ativado. Início em: ${DateTime.now()}');
  }

  /// Desativa o modo de Pânico.
  /// Deve ser chamada APENAS se o tempo mínimo de duração tiver expirado.
  Future<void> deactivateLockdown() async {
    await _initPrefs();
    final isActive = await isLockdownActive();
    
    // Regra de segurança crítica: só permite desativar se o tempo mínimo tiver passado.
    if (!isActive || (await _isDurationExpired())) {
       await _prefs.setBool(_lockdownKey, false);
       await _prefs.remove(_activationTimeKey);
       print('Lockdown Desativado.');
    } else {
       throw Exception("Tentativa de desativação antes do período mínimo de ${MIN_LOCKDOWN_DURATION.inHours}h.");
    }
  }

  /// Função utilitária para checar a expiração
  Future<bool> _isDurationExpired() async {
    final activationTimeMillis = _prefs.getInt(_activationTimeKey);
    if (activationTimeMillis == null) return true; 

    final activationTime = DateTime.fromMillisecondsSinceEpoch(activationTimeMillis);
    final expiryTime = activationTime.add(MIN_LOCKDOWN_DURATION);
    return DateTime.now().isAfter(expiryTime);
  }
}