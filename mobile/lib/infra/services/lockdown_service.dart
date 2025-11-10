import 'dart:async';
import 'package:flutter/foundation.dart';

/// SIMULAÇÃO DE PERSISTÊNCIA LOCAL (Ex: SharedPreferences)
/// Usado para armazenar o timestamp de término do bloqueio de emergência.
class _LocalLockdownStorage {
  // NOTA: Em produção, isto seria substituído por `SharedPreferences` ou `Hive`.
  static final Map<String, String> _storage = {};
  static const String _storageKey = 'lockdownEndTimeUtc';

  Future<String?> read() async {
    await Future.delayed(const Duration(milliseconds: 1)); // Simula async I/O
    return _storage[_storageKey];
  }

  Future<void> write(String value) async {
    await Future.delayed(const Duration(milliseconds: 1));
    _storage[_storageKey] = value;
  }
  
  Future<void> clear() async {
    await Future.delayed(const Duration(milliseconds: 1));
    _storage.remove(_storageKey);
  }
  
  // Método auxiliar para testes (necessário para a arquitetura de Q.R.)
  static void clearAll() => _storage.clear();
}

/// O Serviço de Bloqueio (Lockdown) é responsável pela persistência
/// do estado de "Botão de Pânico" (Missão Anti-Vício).
class LockdownService {
  final _LocalLockdownStorage _localStorage;
  
  // Duração padrão do bloqueio de emergência (Ex: 24 horas)
  final Duration lockdownDuration = const Duration(hours: 24);

  // O construtor é ajustado para facilitar a injeção em testes
  LockdownService({_LocalLockdownStorage? localStorage}) 
      : _localStorage = localStorage ?? _LocalLockdownStorage();

  /// Carrega o timestamp de término do bloqueio salvo no dispositivo.
  /// Retorna nulo se não houver bloqueio ativo ou se o tempo tiver expirado.
  Future<DateTime?> loadLockdownEndTime() async {
    try {
      final isoString = await _localStorage.read();
      
      if (isoString != null && isoString.isNotEmpty) {
        final endTime = DateTime.parse(isoString);
        
        // Se o tempo de bloqueio já passou, limpa o armazenamento e retorna nulo
        if (endTime.isBefore(DateTime.now())) {
          await _localStorage.clear();
          return null;
        }
        return endTime;
      }
      
      return null;
      
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar timestamp de bloqueio: $e');
      }
      return null;
    }
  }

  /// Salva o timestamp de término do bloqueio no dispositivo.
  Future<void> saveLockdownEndTime(DateTime endTime) async {
    try {
      final isoString = endTime.toIso8601String();
      await _localStorage.write(isoString);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao salvar timestamp de bloqueio: $e');
      }
    }
  }

  /// Limpa o estado de bloqueio (para cancelamento administrativo, se necessário)
  Future<void> clearLockdown() async {
    await _localStorage.clear();
  }
  
  // --- Lógica de Negócio ---

  /// Verifica o status atual de bloqueio do usuário.
  /// Retorna o timestamp de termino se estiver bloqueado, ou nulo.
  Future<DateTime?> checkLockdownStatus() async {
    // 1. **Verifica persistência local (Botão de Pânico)**
    final endTime = await loadLockdownEndTime();
    if (endTime != null) {
      return endTime;
    }
    
    // 2. **Verifica regras de Backend/Analytics**
    // (Simulação: Futuramente, integra com BehavioralAnalyticsService)
    
    return null; 
  }

  /// Ativa o Botão de Pânico (Lockdown).
  /// Salva o timestamp de término do bloqueio no armazenamento local.
  Future<DateTime> activateLockdown() async {
    final endTime = DateTime.now().add(lockdownDuration);
    await saveLockdownEndTime(endTime);
    if (kDebugMode) {
      debugPrint("Lockdown ativado. Termino em: $endTime");
    }
    return endTime;
  }
}