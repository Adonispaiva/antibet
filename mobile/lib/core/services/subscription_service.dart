// mobile/lib/core/services/subscription_service.dart

import 'dart:convert';
import 'package:antibet/core/services/storage_service.dart';
import 'package:antibet/features/payments/models/subscription_model.dart';
import 'package:flutter/foundation.dart';

/// Chave de armazenamento para o status da assinatura no StorageService.
const String _kSubscriptionStorageKey = 'user_subscription';

/// ID do plano reservado para o Free Tier (Plano Básico).
const int _kFreePlanId = 0;
/// ID do plano que representa o nível Premium (ou superior).
const int _kPremiumPlanId = 2; 

/// Serviço responsável por gerenciar o status da assinatura do usuário.
/// 
/// Controla se o usuário tem acesso a funcionalidades Premium e persiste 
/// o estado da assinatura localmente.
class SubscriptionService {
  final StorageService _storageService;

  SubscriptionService(this._storageService);

  /// Carrega o SubscriptionModel salvo localmente.
  /// Retorna o modelo FreeTier se não houver dados.
  Future<SubscriptionModel> loadSubscriptionStatus() async {
    try {
      final String? subJson = await _storageService.getString(_kSubscriptionStorageKey);

      if (subJson == null || subJson.isEmpty) {
        debugPrint('SubscriptionService: Nenhum status de assinatura encontrado. Retornando FreeTier.');
        return SubscriptionModel.freeTier();
      }

      final Map<String, dynamic> jsonMap = jsonDecode(subJson);
      return SubscriptionModel.fromJson(jsonMap);

    } catch (e) {
      debugPrint('SubscriptionService loadSubscriptionStatus error: $e');
      // Em caso de erro, sempre retornar o FreeTier para não bloquear o acesso básico.
      return SubscriptionModel.freeTier();
    }
  }

  /// Salva o SubscriptionModel, tipicamente após uma comunicação com a API.
  Future<void> saveSubscriptionStatus(SubscriptionModel subscription) async {
    try {
      final String subJson = jsonEncode(subscription.toJson());
      await _storageService.setString(_kSubscriptionStorageKey, subJson);
      debugPrint('SubscriptionService: Status de assinatura salvo com sucesso.');
    } catch (e) {
      debugPrint('SubscriptionService saveSubscriptionStatus error: $e');
    }
  }

  /// Verifica se o usuário tem uma assinatura Premium ativa.
  /// 
  /// A lógica baseia-se no ID do Plano ser maior ou igual ao ID Premium
  /// e o status da assinatura ser 'active'.
  Future<bool> isPremiumActive() async {
    final subscription = await loadSubscriptionStatus();

    // Uma assinatura é Premium se o planId for >= ao ID Premium (2) 
    // e o status for 'active'.
    final bool isPremium = subscription.planId >= _kPremiumPlanId;
    final bool isActive = subscription.isActive && subscription.status == 'active';
    
    return isPremium && isActive;
  }

  /// Verifica se o usuário está no Plano Básico/Free.
  Future<bool> isFreeTier() async {
    final subscription = await loadSubscriptionStatus();
    return subscription.planId == _kFreePlanId;
  }
}