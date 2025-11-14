// mobile/lib/widgets/premium_gate_widget.dart

import 'package:antibet/features/payments/notifiers/subscription_notifier.dart';
import 'package:flutter/material.dart';
// Assumindo que o Riverpod (ou Provider) é usado para gerenciar o estado. 
// Para este exemplo, usaremos a interface do Provider/Consumer padrão do Flutter/Riverpod.
// Se o projeto for Riverpod: import 'package:flutter_riverpod/flutter_riverpod.dart';
// Se o projeto for Provider: import 'package:provider/provider.dart';

// Definindo um Widget simples de Upsell para uso como placeholder, 
// caso o usuário não tenha fornecido um Widget de Upsell customizado.
class _DefaultUpsellWidget extends StatelessWidget {
  const _DefaultUpsellWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'Conteúdo Premium Bloqueado',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Esta funcionalidade requer uma assinatura Premium ativa. Assine para desbloquear todo o potencial do AntiBet.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Implementar navegação para a tela de Planos (PlansScreen)
                debugPrint('Navegar para tela de Planos');
              },
              child: const Text('Ver Planos de Assinatura'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget que controla o acesso a um recurso/conteúdo com base no status Premium do usuário.
/// 
/// Se o usuário for Premium, exibe o [child]. Caso contrário, exibe o [upsellWidget] 
/// (ou um widget padrão).
class PremiumGateWidget extends StatelessWidget {
  /// O conteúdo que deve ser exibido apenas para usuários Premium.
  final Widget child;

  /// O widget de substituição exibido para usuários não-Premium (ex: tela de compra).
  final Widget? upsellWidget;

  const PremiumGateWidget({
    super.key,
    required this.child,
    this.upsellWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos um Consumer (assumindo a arquitetura SSOT via Provider/Riverpod) para ouvir as mudanças no estado.
    // Adapte o Consumer/Select dependendo da implementação exata de gerenciamento de estado (Provider, Riverpod, BLoC, etc.)
    // Aqui, usamos um construtor de widget simples que acessa o estado.
    
    // --- Início da lógica de Gating ---
    // Exemplo usando Provider:
    // final isPremium = Provider.of<SubscriptionNotifier>(context).isPremium;

    // Exemplo usando Riverpod (assumindo que o Notifier está disponível via um `ref` no Widget):
    // Se estivéssemos em um ConsumerWidget: 
    // final isPremium = ref.watch(subscriptionNotifierProvider).isPremium;
    
    // Para simplificar e manter a portabilidade, vamos simular o acesso ao estado 
    // com a função `context.watch<T>()` do Provider, que é comum:
    try {
      final isPremium = Provider.of<SubscriptionNotifier>(context).isPremium;

      if (isPremium) {
        return child;
      } else {
        return upsellWidget ?? const _DefaultUpsellWidget();
      }
    } on ProviderNotFoundException {
      // Caso o Notifier não esteja no Provider scope (erro de setup), retorna o Child para não bloquear totalmente.
      debugPrint('ERRO: SubscriptionNotifier não encontrado no Provider Scope. Exibindo conteúdo como fallback.');
      return child; 
    } catch (e) {
      // Outros erros de estado.
      debugPrint('ERRO no PremiumGateWidget: $e. Exibindo Upsell.');
      return upsellWidget ?? const _DefaultUpsellWidget();
    }
  }
}