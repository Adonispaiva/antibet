// mobile/lib/features/goals/screens/goals_screen.dart

import 'package:antibet/features/goals/models/goal_model.dart';
import 'package:antibet/features/goals/notifiers/goals_notifier.dart';
import 'package:flutter/material.dart';
// Assumindo o uso de Provider/Riverpod para gerenciar o estado
import 'package:provider/provider.dart'; 

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta as mudanças no GoalsNotifier
    final goalsNotifier = context.watch<GoalsNotifier>();
    final goals = goalsNotifier.goals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Metas'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddGoalDialog(context, goalsNotifier),
          ),
        ],
      ),
      body: goalsNotifier.isLoading
          ? const Center(child: CircularProgressIndicator())
          : goalsNotifier.errorMessage != null
              ? Center(child: Text('Erro: ${goalsNotifier.errorMessage}'))
              : goals.isEmpty
                  ? const Center(
                      child: Text('Você ainda não tem metas. Clique no "+" para adicionar uma!'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: goals.length,
                      itemBuilder: (context, index) {
                        final goal = goals[index];
                        return GoalCard(
                          goal: goal,
                          onToggleComplete: () => _toggleGoalCompletion(context, goalsNotifier, goal),
                          onDelete: () => _deleteGoal(context, goalsNotifier, goal.id!),
                        );
                      },
                    ),
    );
  }
  
  void _toggleGoalCompletion(BuildContext context, GoalsNotifier notifier, GoalModel goal) {
    final updatedGoal = goal.copyWith(
      isCompleted: !goal.isCompleted,
      completionDate: goal.isCompleted ? const ValueGetter(() => null)() : DateTime.now(), // Atualiza/limpa data
    );
    notifier.updateGoal(updatedGoal);
  }
  
  void _deleteGoal(BuildContext context, GoalsNotifier notifier, int goalId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja remover esta meta?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              notifier.removeGoal(goalId);
              Navigator.of(ctx).pop();
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context, GoalsNotifier notifier) {
    final titleController = TextEditingController();
    final targetAmountController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova Meta'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título da Meta'),
              ),
              TextField(
                controller: targetAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Valor Alvo (R\$)'),
              ),
              // Simplificado: TargetDate e Descrição omitidos para manter o foco no essencial
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && double.tryParse(targetAmountController.text) != null) {
                final newGoal = GoalModel(
                  title: titleController.text,
                  targetAmount: double.parse(targetAmountController.text),
                  creationDate: DateTime.now(),
                  targetDate: DateTime.now().add(const Duration(days: 90)), // 3 meses padrão
                );
                notifier.addGoal(newGoal);
                Navigator.of(ctx).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preencha o título e o valor alvo corretamente.')),
                );
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }
}

/// Widget reutilizável para exibir os detalhes de uma meta.
class GoalCard extends StatelessWidget {
  final GoalModel goal;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onToggleComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = goal.targetAmount > 0 ? goal.currentAmount / goal.targetAmount : 0.0;
    final int progressPercent = (progress * 100).toInt().clamp(0, 100);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: goal.isCompleted ? Colors.green.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration: goal.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') onDelete();
                    if (value == 'toggle') onToggleComplete();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'toggle',
                      child: Text(goal.isCompleted ? 'Marcar como Pendente' : 'Marcar como Concluída'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Excluir', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Alvo: R\$ ${goal.targetAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey)),
            Text('Progresso: R\$ ${goal.currentAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              color: goal.isCompleted ? Colors.green : Colors.blue,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${progressPercent}% Completo', style: const TextStyle(fontSize: 12)),
                Text('Prazo: ${goal.targetDate.day}/${goal.targetDate.month}/${goal.targetDate.year}', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}