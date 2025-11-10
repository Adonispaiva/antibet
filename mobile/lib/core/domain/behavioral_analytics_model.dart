import 'package:flutter/foundation.dart';

/// Entidade de Domínio que representa a análise comportamental do usuário.
/// Esta entidade é crucial para a Missão Anti-Vício, calculando um Escore de Risco.
@immutable
class BehavioralAnalyticsModel {
  // Frequência de Login (Ex: média de logins por dia nas últimas 72h)
  final double loginFrequency; 
  
  // Tempo Médio no App (Ex: média de minutos por sessão)
  final double avgSessionDurationInMinutes; 
  
  // Total de ativações do "Botão de Pânico" nos últimos 30 dias
  final int panicActivations; 
  
  // Escore de Risco Calculado (0.0 a 1.0)
  final double riskScore; 

  const BehavioralAnalyticsModel({
    required this.loginFrequency,
    required this.avgSessionDurationInMinutes,
    required this.panicActivations,
    required this.riskScore,
  });

  /// Construtor Padrão (Estado Inicial/Seguro)
  factory BehavioralAnalyticsModel.defaultValues() {
    return const BehavioralAnalyticsModel(
      loginFrequency: 0.0,
      avgSessionDurationInMinutes: 0.0,
      panicActivations: 0,
      riskScore: 0.0, // Risco Baixo
    );
  }

  /// Construtor de fábrica para desserialização JSON (API/Cache)
  factory BehavioralAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return BehavioralAnalyticsModel(
      loginFrequency: (json['loginFrequency'] as num? ?? 0.0).toDouble(),
      avgSessionDurationInMinutes: (json['avgSessionDurationInMinutes'] as num? ?? 0.0).toDouble(),
      panicActivations: json['panicActivations'] as int? ?? 0,
      riskScore: (json['riskScore'] as num? ?? 0.0).toDouble(),
    );
  }

  /// Método para serialização JSON (Cache/API)
  Map<String, dynamic> toJson() {
    return {
      'loginFrequency': loginFrequency,
      'avgSessionDurationInMinutes': avgSessionDurationInMinutes,
      'panicActivations': panicActivations,
      'riskScore': riskScore,
    };
  }

  // Sobrescreve hashCode e equals
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BehavioralAnalyticsModel &&
      other.loginFrequency == loginFrequency &&
      other.avgSessionDurationInMinutes == avgSessionDurationInMinutes &&
      other.panicActivations == panicActivations &&
      other.riskScore == riskScore;
  }

  @override
  int get hashCode {
    return loginFrequency.hashCode ^
      avgSessionDurationInMinutes.hashCode ^
      panicActivations.hashCode ^
      riskScore.hashCode;
  }
}