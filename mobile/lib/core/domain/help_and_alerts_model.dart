import 'package:flutter/foundation.dart';

/// Sub-Entidade para representar um recurso de ajuda externa (Ex: site, telefone de apoio).
@immutable
class HelpResourceModel {
  final String title;
  final String url;
  final String type; // Ex: 'website', 'phone', 'video'

  const HelpResourceModel({
    required this.title,
    required this.url,
    required this.type,
  });

  factory HelpResourceModel.fromJson(Map<String, dynamic> json) {
    return HelpResourceModel(
      title: json['title'] as String,
      url: json['url'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'type': type,
    };
  }
}


/// Entidade de Domínio que agrega o conteúdo e status para o Módulo de Alertas e Ajuda.
/// Esta entidade é crucial para a Missão Anti-Vício.
@immutable
class HelpAndAlertsModel {
  // Lista de recursos de apoio psicológico e sites informativos
  final List<HelpResourceModel> supportResources; 
  
  // Detalhes do último alerta interno acionado
  final String? lastTriggeredAlert; 
  
  // Timestamp do último alerta
  final DateTime? lastAlertTimestamp; 

  const HelpAndAlertsModel({
    required this.supportResources,
    this.lastTriggeredAlert,
    this.lastAlertTimestamp,
  });

  /// Construtor de fábrica para desserialização JSON (API/Cache)
  factory HelpAndAlertsModel.fromJson(Map<String, dynamic> json) {
    return HelpAndAlertsModel(
      supportResources: (json['supportResources'] as List<dynamic>?)
          ?.map((e) => HelpResourceModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      lastTriggeredAlert: json['lastTriggeredAlert'] as String?,
      lastAlertTimestamp: json['lastAlertTimestamp'] != null 
          ? DateTime.parse(json['lastAlertTimestamp'] as String) 
          : null,
    );
  }

  /// Método para serialização JSON (Cache/API)
  Map<String, dynamic> toJson() {
    return {
      'supportResources': supportResources.map((e) => e.toJson()).toList(),
      'lastTriggeredAlert': lastTriggeredAlert,
      'lastAlertTimestamp': lastAlertTimestamp?.toIso8601String(),
    };
  }

  /// Cria uma cópia da entidade (imutabilidade)
  HelpAndAlertsModel copyWith({
    List<HelpResourceModel>? supportResources,
    String? lastTriggeredAlert,
    DateTime? lastAlertTimestamp,
  }) {
    return HelpAndAlertsModel(
      supportResources: supportResources ?? this.supportResources,
      lastTriggeredAlert: lastTriggeredAlert ?? this.lastTriggeredAlert,
      lastAlertTimestamp: lastAlertTimestamp ?? this.lastAlertTimestamp,
    );
  }

  // Sobrescreve hashCode e equals
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HelpAndAlertsModel &&
      listEquals(other.supportResources, supportResources) &&
      other.lastTriggeredAlert == lastTriggeredAlert &&
      other.lastAlertTimestamp == lastAlertTimestamp;
  }

  @override
  int get hashCode {
    return supportResources.hashCode ^
      lastTriggeredAlert.hashCode ^
      lastAlertTimestamp.hashCode;
  }
}