// mobile/lib/features/payments/notifiers/subscription_notifier.dart

import 'package:antibet/core/services/subscription_service.dart';
import 'package:antibet/features/payments/models/subscription_model.dart';
import 'package:flutter/foundation.dart';

/// Notifier responsável por expor o estado da assinatura do usuário à UI.
/// 
/// Depende do [SubscriptionService] para persistir e carregar os dados.
class SubscriptionNotifier extends ChangeNotifier {
  final SubscriptionService _subscriptionService;

  // Estado interno do SubscriptionModel
  SubscriptionModel _subscription = SubscriptionModel.freeTier();

  SubscriptionNotifier(this._subscriptionService) {
    _loadInitialSubscription();
  }

  /// Retorna o modelo de assinatura atual (apenas leitura).
  SubscriptionModel get subscription => _subscription;

  /// Retorna se o usuário tem uma assinatura Premium ativa.
  bool get isPremium => _subscription.planId >= 2 && _subscription.isActive;

  /// Retorna se o usuário está no plano básico/livre.
  bool get isFreeTier => _subscription.planId == 0 && _subscription.isActive;

  /// Carrega o status da assinatura do serviço na inicialização.
  Future<void> _loadInitialSubscription() async {
    _subscription = await _subscriptionService.loadSubscriptionStatus();
    notifyListeners();
    debugPrint('SubscriptionNotifier: Estado inicial carregado: Plan ID ${_subscription.planId}');
  }

  /// Atualiza o status da assinatura (usado após login ou evento de webhook/compra).
  /// 
  /// Salva o novo modelo de assinatura e notifica os ouvintes da UI.
  Future<void> updateSubscription(SubscriptionModel newSubscription) async {
    if (newSubscription.planId == _subscription.planId && 
        newSubscription.status == _subscription.status) {
      // Evita salvar e notificar se o status for idêntico.
      return; 
    }
    
    _subscription = newSubscription;
    await _subscriptionService.saveSubscriptionStatus(newSubscription);
    notifyListeners();
    debugPrint('SubscriptionNotifier: Estado de assinatura atualizado para Plan ID ${_subscription.planId}.');
  }

  /// Reseta o estado da assinatura para o Free Tier (usado no Logout).
  Future<void> resetSubscription() async {
    await _subscriptionService.saveSubscriptionStatus(SubscriptionModel.freeTier());
    _subscription = SubscriptionModel.freeTier();
    notifyListeners();
    debugPrint('SubscriptionNotifier: Estado de assinatura resetado para FreeTier.');
  }
}