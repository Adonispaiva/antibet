import 'package:flutter/material.dart';
import 'package:inovexa_antibet/models/plan.model.dart';
import 'package:inovexa_antibet/providers/auth_provider.dart';
import 'package:inovexa_antibet/providers/plans_provider.dart';
import 'package:inovexa_antibet/utils/app_colors.dart';
import 'package:inovexa_antibet/utils/app_typography.dart';
import 'package:inovexa_antibet/widgets/app_layout.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // (Novo)

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  // (Novo) Estado de loading local para o botão
  bool _isCheckoutLoading = false;

  /// (Novo) Lida com a chamada de checkout
  Future<void> _handleUpgrade(BuildContext context, Plan plan) async {
    setState(() { _isCheckoutLoading = true; });

    final provider = Provider.of<PlansProvider>(context, listen: false);
    final url = await provider.createCheckoutSession(plan.id);

    if (url != null) {
      // Tenta abrir a URL de checkout
      if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o link de pagamento.')),
        );
      }
    } else {
      // Exibe o erro do provider
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.checkoutError ?? 'Erro desconhecido.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
    
    if (mounted) {
      setState(() { _isCheckoutLoading = false; });
    }
  }


  @override
  Widget build(BuildContext context) {
    final currentPlanId = context.watch<AuthProvider>().currentUser?.plan.id;

    return AppLayout(
      title: 'Gerenciar Plano',
      showAppBar: true,
      child: Consumer<PlansProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          // ... (Restante da UI v1.1 mantida) ...
          return ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: provider.plans.length,
            itemBuilder: (context, index) {
              final plan = provider.plans[index];
              final bool isCurrentPlan = (plan.id == currentPlanId);
              
              return _buildPlanCard(context, plan, isCurrentPlan, provider);
            },
          );
        },
      ),
    );
  }

  /// Helper (Atualizado v1.2)
  Widget _buildPlanCard(BuildContext context, Plan plan, bool isCurrentPlan, PlansProvider provider) {
    return Card(
      // ... (Estilização v1.1 mantida) ...
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ... (UI v1.1 mantida: Nome, Preço, Descrição, Benefícios) ...
            
            const SizedBox(height: 24),

            // Botão de Ação (Atualizado v1.2)
            if (_isCheckoutLoading && !isCurrentPlan)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                // (Lógica v1.1) Desabilitado se for o plano atual
                onPressed: isCurrentPlan ? null : () => _handleUpgrade(context, plan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCurrentPlan ? AppColors.surfaceLight : AppColors.primary,
                ),
                child: Text(isCurrentPlan ? 'Plano Ativo' : 'Fazer Upgrade'),
              ),
          ],
        ),
      ),
    );
  }
}