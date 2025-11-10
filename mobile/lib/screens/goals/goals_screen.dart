import 'package:flutter/material.dart';
import 'package:inovexa_antibet/models/goal.model.dart';
import 'package:inovexa_antibet/providers/goals_provider.dart';
import 'package:inovexa_antibet/screens/goals/add_goal_screen.dart';
import 'package:inovexa_antibet/widgets/app_layout.dart';
import 'package:inovexa_antibet/widgets/goal_list_item.dart';
import 'package:provider/provider.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  
  // Abre o modal de Adicionar/Editar
  void _showGoalModal({Goal? goal}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      builder: (ctx) {
        return AddGoalScreen(goal: goal);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Minhas Metas',
      showAppBar: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGoalModal(),
        child: const Icon(Icons.add),
      ),
      child: Consumer<GoalsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.goals.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Text('Erro ao carregar metas: ${provider.error}'),
            );
          }

          if (provider.goals.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma meta definida ainda.\nUse o botão (+) para criar sua primeira meta.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: provider.goals.length,
            itemBuilder: (context, index) {
              final goal = provider.goals[index];
              return GoalListItem(
                goal: goal,
                onTap: () => _showGoalModal(goal: goal), // Modo Edição
              );
            },
          );
        },
      ),
    );
  }
}