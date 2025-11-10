import 'package:flutter/material.dart';
import 'package:inovexa_antibet/models/goal.model.dart';
import 'package:inovexa_antibet/providers/goals_provider.dart';
import 'package:inovexa_antibet/utils/app_colors.dart';
import 'package:inovexa_antibet/utils/app_typography.dart';
import 'package:provider/provider.dart';

class GoalListItem extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap; // Para edição

  const GoalListItem({
    super.key,
    required this.goal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);

    return Dismissible(
      key: ValueKey(goal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: AppColors.textLight),
      ),
      onDismissed: (direction) {
        goalsProvider.deleteGoal(goal.id);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        color: AppColors.surfaceLight,
        elevation: 1,
        child: CheckboxListTile(
          title: Text(
            goal.title,
            style: AppTypography.body.copyWith(
              decoration: goal.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          subtitle: goal.description != null && goal.description!.isNotEmpty
              ? Text(
                  goal.description!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    decoration: goal.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                )
              : null,
          value: goal.isCompleted,
          onChanged: (bool? newValue) {
            if (newValue != null) {
              goalsProvider.updateGoal(goal.id, {'isCompleted': newValue});
            }
          },
          // Permite que o usuário toque no item para editar
          secondary: IconButton(
            icon: const Icon(Icons.edit_note, color: AppColors.primary),
            onPressed: onTap,
          ),
        ),
      ),
    );
  }
}