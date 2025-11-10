import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:antibet/src/core/notifiers/lockdown_notifier.dart';
import 'package:antibet/src/core/notifiers/behavioral_analytics_notifier.dart';
import 'package:antibet/src/widgets/risk_intervention_widget.dart'; // O Widget que acabamos de testar

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Observa os notifiers essenciais
    final analyticsNotifier = context.watch<BehavioralAnalyticsNotifier>();
    final lockdownNotifier = context.read<LockdownNotifier>(); // read pois só aciona, não precisa rebuildar a tela inteira

    return Scaffold(
      appBar: AppBar(
        title: const Text('AntiBet Home'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
        actions: [
          // Exibição do Escore de Risco na AppBar
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Risco: ${analyticsNotifier.riskScore}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: analyticsNotifier.isHighRisk ? Colors.redAccent : Colors.lightGreenAccent,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. INTEGRAÇÃO DO WIDGET DE INTERVENÇÃO ATIVA
            // Este widget só aparece se o risco for ALTO (lógica interna dele).
            const RiskInterventionWidget(), 
            
            const SizedBox(height: 20),
            
            // 2. CARDS INTERATIVOS (Fluxo do App)
            const Text(
              'Sua Jornada AntiBet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _buildHomeCard(
              context,
              icon: Icons.chat_bubble_outline,
              title: 'Reflexões AntiBet', // 'Reflexões AntiBet'
              subtitle: 'Converse com a IA Coach e faça seu check-in diário.',
              onTap: () => context.go('/chat'), // Rota simulada para o Chat
            ),
            _buildHomeCard(
              context,
              icon: Icons.bar_chart,
              title: 'Meu Progresso', // 'Meu progresso'
              subtitle: 'Dias sem apostar e metas pessoais alcançadas.',
              onTap: () => context.go('/progress'), // Rota simulada para Progresso
            ),
            _buildHomeCard(
              context,
              icon: Icons.lock_open,
              title: 'Ferramentas de Autocontrole',
              subtitle: 'Bloqueio de sites, limites de depósito e timer.',
              onTap: () => context.go('/prevention'), // Rota para Prevenção
            ),
          ],
        ),
      ),
      
      // 3. BOTÃO DE EMERGÊNCIA (SOS) - CTA no rodapé
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Ação: Acionar o Botão de Pânico (Lockdown)
          lockdownNotifier.activateLockdown();
          // Redireciona para a tela de lockdown, o AppRouter já faria isso, mas forçamos.
          context.go('/lockdown');
        },
        icon: const Icon(Icons.warning_amber_rounded, size: 28),
        label: const Text(
          'Botão de Emergência (SOS)', // 'Botão de emergência'
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }

  Widget _buildHomeCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.blueGrey, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}