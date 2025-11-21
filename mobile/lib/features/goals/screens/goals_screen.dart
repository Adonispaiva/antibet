import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:antibet/features/goals/providers/goals_provider.dart';
import 'package:antibet/features/shared/widgets/app_layout.dart'; // Importação do AppLayout
import 'package:antibet/features/shared/widgets/empty_state_widget.dart'; // Importação do EmptyStateWidget
import 'package:antibet/core/routing/app_router.dart'; // Para navegação
import 'package:antibet/core/styles/app_colors.dart';


// O decorator @RoutePage é exigido pelo auto_route
@RoutePage()
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  // Acessamos o GoalsProvider para gerenciar o estado das metas
  final GoalsProvider _goalsProvider = GetIt.I<GoalsProvider>();

  @override
  void initState() {
    super.initState();
    // Dispara o carregamento inicial dos dados após o widget ser montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _goalsProvider.fetchGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Note: Esta tela é uma aba, o AppBar é definido na MainShellScreen.
    return ListenableBuilder(
      listenable: _goalsProvider,
      builder: (context, child) {
        
        // 1. Loading State (overlay no AppLayout)
        final bool isLoading = _goalsProvider.isLoading && _goalsProvider.goals.isEmpty;

        Widget content;

        // 2. Error State
        if (_goalsProvider.errorMessage != null) {
          content = EmptyStateWidget.error(
            title: 'Erro de Conexão',
            subtitle: _goalsProvider.errorMessage,
            action: ElevatedButton.icon(
              onPressed: _goalsProvider.fetchGoals,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          );
        }
        
        // 3. Empty State
        else if (_goalsProvider.goals.isEmpty && !_goalsProvider.isLoading) {
          content = EmptyStateWidget.noData(
            title: 'Nenhuma Meta',
            subtitle: 'Defina suas metas financeiras para monitorar seu progresso.',
            action: ElevatedButton.icon(
              onPressed: () {
                context.router.push(const GoalCreationRoute()); // Navega para criação
              },
              icon: const Icon(Icons.add),
              label: const Text('Definir Nova Meta'),
            ),
          );
        }

        // 4. Data Display State
        else {
          content = ListView.builder(
            itemCount: _goalsProvider.goals.length,
            itemBuilder: (context, index) {
              final goal = _goalsProvider.goals[index];
              // Garante que o progresso não seja NaN ou infinito
              final progress = goal.targetValue > 0 ? (goal.currentValue / goal.targetValue).clamp(0.0, 1.0) : 0.0;
              final isCompleted = goal.status == 'COMPLETED';

              return ListTile(
                leading: CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? AppColors.accentGreen : AppColors.primaryBlue),
                ),
                title: Text(goal.title),
                subtitle: Text('Progresso: ${(progress * 100).toStringAsFixed(0)}% | ${goal.status}'),
                trailing: Text(
                  'Alvo: R\$${goal.targetValue.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  context.router.push(GoalDetailRoute(goalId: goal.id));
                },
              );
            },
          );
        }

        // A tela de aba não usa AppLayout para o Scaffold, mas sim para o conteúdo.
        // O FAB deve estar no Scaffold da aba, não no AppLayout
        return Scaffold(
          body: AppLayout(
            isLoading: isLoading, // Controla o overlay de loading
            appBar: null, // O AppBar vem da MainShellScreen
            useSafeArea: false, // O Scaffold já cuida disso
            child: Padding(
              padding: EdgeInsets.zero, // Remove o padding horizontal do AppLayout para a lista
              child: content,
            ),
          ),
          // FAB para adicionar nova entrada
          floatingActionButton: FloatingActionButton(
            onPressed: isLoading ? null : () {
              context.router.push(const GoalCreationRoute()); 
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}