// mobile/lib/features/payments/models/subscription_model.dart

import 'dart:convert';
import 'package:flutter/foundation.dart'; // Para listEquals e debugPrint (não estritamente necessário aqui, mas bom para consistência)

/// Representa o status atual da assinatura do usuário.
/// É a base para todas as verificações de acesso a recursos Premium.
class SubscriptionModel {
  final int planId;
  final bool isActive;
  final String status; // Ex: 'active', 'pending', 'cancelled', 'expired'
  final DateTime startDate;
  final DateTime? endDate; // Nulo se for assinatura vitalícia ou se for Free Tier (sem fim)
  final String? gatewaySubscriptionId; // ID da assinatura no Stripe, por exemplo

  const SubscriptionModel({
    required this.planId,
    required this.isActive,
    required this.status,
    required this.startDate,
    this.endDate,
    this.gatewaySubscriptionId,
  });

  /// Construtor de fábrica para um estado inicial de "Plano Básico/Livre".
  factory SubscriptionModel.freeTier() {
    return SubscriptionModel(
      planId: 0, // ID 0 reservado para o plano Básico/Free
      isActive: true, // O acesso básico é sempre ativo
      status: 'active',
      startDate: DateTime.now(),
      endDate: null,
      gatewaySubscriptionId: null,
    );
  }

  /// Constrói um SubscriptionModel a partir de um mapa JSON.
  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      planId: json['planId'] as int,
      isActive: json['isActive'] as bool,
      status: json['status'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      gatewaySubscriptionId: json['gatewaySubscriptionId'] as String?,
    );
  }

  /// Converte o SubscriptionModel para um mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'isActive': isActive,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'gatewaySubscriptionId': gatewaySubscriptionId,
    };
  }
  
  /// Cria uma cópia imutável do SubscriptionModel com valores opcionais substituídos.
  SubscriptionModel copyWith({
    int? planId,
    bool? isActive,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? gatewaySubscriptionId,
  }) {
    return SubscriptionModel(
      planId: planId ?? this.planId,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      gatewaySubscriptionId: gatewaySubscriptionId ?? this.gatewaySubscriptionId,
    );
  }

  // Omitindo a sobrecarga de hashCode e operator == por não serem cruciais para a persistência.
}