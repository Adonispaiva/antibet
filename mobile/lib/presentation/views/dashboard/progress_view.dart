import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:antibet/src/core/notifiers/dashboard_notifier.dart';
import 'package:antibet/src/core/services/dashboard_service.dart'; // Para acessar o modelo Goal

// Cor de Sucesso (Verde Escuro)
const Color _successColor = Color(0xFF2E7D32); 

class ProgressView extends StatelessWidget {
  const ProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<DashboardNotifier>();

    // Simulação da Métrica Chave: Dias sem Apostar
    const int daysWithoutBetting = 125; 

    // Calcula metas concluídas
    final int completedGoals = notifier.userGoals.where((g) => g.isCompleted).length;
    final int totalGoals = notifier.userGoals.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Progresso'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Suas Vitórias',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            const SizedBox(height: 10),

            // 1. Placar Chave: Dias Sem Apostar
            _buildDaysCounter(context, daysWithoutBetting),
            const SizedBox(height: 30),

            // 2. Título do Módulo de Metas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Metas Pessoais ($completedGoals/$totalGoals)',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: _successColor),
                  onPressed: () => context.go('/dashboard/add-goal'),
                  tooltip: 'Adicionar nova meta',
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 3. Lista de Metas (Metas e Gamificação)
            if (notifier.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (notifier.userGoals.isEmpty)
              const Center(child: Text('Nenhuma meta definida. Adicione sua primeira meta!'))
            else
              ...notifier.userGoals.map((goal) => _buildGoalTile(context, goal, notifier)),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // Card para o Contador de Dias
  Widget _buildDaysCounter(BuildContext context, int days) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(25.0),
        decoration: BoxDecoration(
          color: _successColor.withOpacity(0.95),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            const Text(
              'Você está livre de apostas há:',
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$days',
                  style: const TextStyle(
                    fontSize: 70,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'DIAS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            const Text(
              'Uma grande conquista em sua jornada!',
              style: TextStyle(fontSize: 14, color: Colors.white70, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  // Tile para cada meta (com funcionalidade de check)
  Widget _buildGoalTile(BuildContext context, Goal goal, DashboardNotifier notifier) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 1,
      child: ListTile(
        leading: Icon(
          goal.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: goal.isCompleted ? _successColor : Colors.grey,
        ),
        title: Text(
          goal.title,
          style: TextStyle(
            decoration: goal.isCompleted ? TextDecoration.lineThrough : null,
            color: goal.isCompleted ? Colors.grey : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: goal.isCompleted
            ? null
            : IconButton(
                icon: const Icon(Icons.star, color: Colors.amber),
                onPressed: () {
                  // Ação: Marcar como completa (reforço positivo)
                  notifier.completeGoal(goal.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Meta concluída! Parabéns pela sua força!')),
                  );
                },
                tooltip: 'Marcar como concluída',
              ),
      ),
    );
  }
}