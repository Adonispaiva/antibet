import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import 'package:antibet/features/goals/models/goal_model.dart';
import 'package:antibet/features/goals/providers/goals_provider.dart';
import 'package:antibet/features/shared/widgets/app_layout.dart'; // Importação do AppLayout
import 'package:antibet/features/shared/widgets/action_separator.dart'; // Importação do ActionSeparator


// O decorator @RoutePage é exigido pelo auto_route
@RoutePage()
class GoalDetailScreen extends StatelessWidget {
  // O ID da meta é um parâmetro obrigatório na rota
  final String goalId; 

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context) {
    final GoalsProvider goalsProvider = GetIt.I<GoalsProvider>();
    
    // Procura a meta na lista carregada no Provider
    // Usamos ListenableBuilder para reagir a mudanças no estado (ex: após deleção ou atualização)
    return ListenableBuilder(
      listenable: goalsProvider,
      builder: (context, child) {
        final goal = goalsProvider.goals.firstWhere(
          (g) => g.id == goalId,
          orElse: () => throw Exception('Meta não encontrada.'), 
        ); 

        final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
        final dateFormat = DateFormat('dd/MM/yyyy');
        
        // Calcula o progresso (garantindo que não divida por zero)
        final progress = goal.targetValue > 0 ? (goal.currentValue / goal.targetValue).clamp(0.0, 1.0) : 0.0;
        final isCompleted = goal.status == 'COMPLETED';

        return AppLayout( // Substitui o Scaffold principal
          appBar: AppBar(
            title: Text('Meta: ${goal.title}'),
            actions: [
              // Botão de Editar
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // context.router.push(EditGoalRoute(goal: goal)); // Rota futura
                },
              ),
              // Botão de Excluir
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(context, goalId, goalsProvider),
              ),
            ],
          ),
          child: SingleChildScrollView(
            // Padding removido, agora está no AppLayout
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // --- Indicador de Progresso ---
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 10,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? Colors.green : Colors.blue),
                        ),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
    
                // --- Dados de Valor ---
                _buildDetailRow(context, 'Valor Alvo:', currencyFormat.format(goal.targetValue)),
                _buildDetailRow(context, 'Valor Atual:', currencyFormat.format(goal.currentValue)),
                
                const ActionSeparator(), // Separador padronizado
    
                // --- Status e Datas ---
                _buildDetailRow(context, 'Status:', goal.status),
                _buildDetailRow(context, 'Data de Início:', dateFormat.format(goal.startDate)),
                _buildDetailRow(context, 'Data de Fim:', dateFormat.format(goal.endDate)),
                
                const ActionSeparator(), // Separador padronizado
    
                // --- Descrição ---
                Text('Descrição da Meta:', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    goal.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Widget utilitário para formatar uma linha de detalhe.
  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  /// Exibe um diálogo de confirmação antes de excluir.
  void _confirmDelete(BuildContext context, String goalId, GoalsProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza de que deseja excluir permanentemente esta meta?'),
        actions: [
          TextButton(
            onPressed: () => context.router.pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              context.router.pop(); // Fecha o diálogo
              await provider.deleteGoal(goalId); // Chama a exclusão
              context.router.pop(); // Retorna para a lista
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}