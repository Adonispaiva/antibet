// mobile/lib/features/plans/screens/plans_screen.dart

import 'package:antibet/core/services/payments_api_service.dart';
import 'package:antibet/core/services/plans_service.dart';
import 'package:antibet/features/plans/models/plan_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Para abrir a URL de checkout

// Assumindo a injeção via Riverpod/Provider para acessar os serviços
// Exemplo: final paymentsApiService = ref.read(paymentsApiServiceProvider);
// Exemplo: final plansService = ref.read(plansServiceProvider);
// Usaremos `Provider.of` para simular o acesso no `build`

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  late Future<List<PlanModel>> _plansFuture;

  @override
  void initState() {
    super.initState();
    // Inicia o carregamento dos planos (usando PlansService que retorna dados estáticos)
    // Em um cenário real com Riverpod/Provider, faríamos isso no Notifier ou usaria um FutureProvider.
    _loadPlans();
  }
  
  void _loadPlans() {
    // Acessa o PlansService para obter a lista (que é estática/simulada)
    // Usando uma instância temporária para simulação
    final plansService = PlansService(); 
    _plansFuture = plansService.loadPlans();
  }

  /// Inicia o fluxo de pagamento chamando o Backend e abrindo a URL.
  Future<void> _initiateCheckout(PlanModel plan) async {
    // Em um cenário real, usaria o Provider.of<PaymentsApiService>(context)
    final paymentsApiService = PaymentsApiService(); 
    
    try {
      // 1. Chama o Backend para criar a sessão de checkout
      final redirectUrl = await paymentsApiService.createCheckoutSession(plan.id);

      // 2. Redireciona o usuário para o URL do gateway de pagamento
      if (await canLaunchUrl(Uri.parse(redirectUrl))) {
        await launchUrl(Uri.parse(redirectUrl), mode: LaunchMode.externalApplication);
      } else {
        throw 'Não foi possível abrir a URL de pagamento: $redirectUrl';
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao iniciar pagamento: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nossos Planos de Assinatura'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<PlanModel>>(
        future: _plansFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar planos: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum plano disponível no momento.'));
          }

          final plans = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return PlanCard(
                plan: plan,
                onSelect: _initiateCheckout,
                isPopular: plan.isPopular,
              );
            },
          );
        },
      ),
    );
  }
}

/// Widget reutilizável para exibir os detalhes de um plano.
class PlanCard extends StatelessWidget {
  final PlanModel plan;
  final Function(PlanModel) onSelect;
  final bool isPopular;

  const PlanCard({
    super.key,
    required this.plan,
    required this.onSelect,
    this.isPopular = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isPopular ? Colors.blue.shade50 : null,
      elevation: isPopular ? 4 : 2,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPopular)
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text('MAIS POPULAR', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
            Text(
              plan.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'R\$ ${plan.price.toStringAsFixed(2)} / ${plan.period}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.green.shade700),
            ),
            const SizedBox(height: 16),
            ...plan.features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 18, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  Flexible(child: Text(feature)),
                ],
              ),
            )).toList(),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () => onSelect(plan),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Assinar Agora'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}