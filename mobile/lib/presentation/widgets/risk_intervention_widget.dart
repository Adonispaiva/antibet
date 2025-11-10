import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Importações dos notifiers e rotas
import '../../notifiers/behavioral_analytics_notifier.dart';
import '../../core/navigation/app_router.dart';

/// Um widget de intervenção ativa que aparece quando o Escore de Risco
/// do usuário atinge um nível crítico (Missão Anti-Vício).
class RiskInterventionWidget extends StatelessWidget {
  const RiskInterventionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta o notifier de análise comportamental
    final analyticsNotifier = context.watch<BehavioralAnalyticsNotifier>();
    final double riskScore = analyticsNotifier.riskScore;

    // Define o limite de risco crítico (Alto Risco no HomeView é > 0.7)
    const double criticalRiskThreshold = 0.7; 

    if (riskScore < criticalRiskThreshold) {
      // Não exibe nada se o risco for baixo ou moderado
      return const SizedBox.shrink();
    }

    // Se o risco for alto (criticalRiskThreshold)
    return Card(
      color: Colors.red[50], // Fundo levemente vermelho para destaque
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.red, size: 28),
                const SizedBox(width: 10),
                Text(
                  'ALERTA DE ALTO RISCO!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.red),
            const Text(
              'O seu Escore de Risco Comportamental está CRÍTICO. Isso pode indicar uma perda de controle. Por favor, utilize os recursos de prevenção.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 15),

            // Botão de Intervenção Rápida (Botão de Pânico)
            ElevatedButton.icon(
              onPressed: () {
                // Navega para a tela de Ajuda/SOS (o AppRouter faz o trabalho)
                context.goNamed(AppRoute.help.name); 
              },
              icon: const Icon(Icons.support_agent),
              label: const Text('ACESSAR AJUDA IMEDIATA', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45), // Botão de largura total
              ),
            ),
            const SizedBox(height: 10),
            
            // Sugestão para o Bloqueio de Pânico
            TextButton(
              onPressed: () {
                 // Assumimos que o Botão de Pânico está na HomeView e o usuário será alertado.
                 // O objetivo é incentivar o acionamento do Bloqueio de Pânico.
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Por favor, ative o "Bloqueio de Pânico" logo abaixo se o impulso for forte.')),
                 );
              },
              child: const Text('Lembrete: Considere o Bloqueio de Pânico (SOS)', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}