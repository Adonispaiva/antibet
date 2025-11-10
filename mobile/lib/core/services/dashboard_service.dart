import 'dart:math';

// Modelo de dados para Metas Pessoais
class Goal {
  final String id;
  final String title;
  final bool isCompleted;

  Goal({required this.id, required this.title, this.isCompleted = false});
  
  Goal copyWith({bool? isCompleted}) {
    return Goal(
      id: id,
      title: title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

// Modelo de dados para Reflexões Diárias da IA
class Reflection {
  final String title;
  final String content;
  final String source; // Ex: TCC, Mindfulness

  Reflection({required this.title, required this.content, required this.source});
}


class DashboardService {
  // --- Dados Simulados ---
  final List<Goal> _userGoals = [
    Goal(id: 'g1', title: 'Evitar o celular na primeira hora do dia', isCompleted: true),
    Goal(id: 'g2', title: 'Reservar 10 min para Mindfulness', isCompleted: false),
    Goal(id: 'g3', title: 'Rever o Painel Financeiro antes das 18h', isCompleted: false),
  ];
  
  final List<Reflection> _dailyReflections = [
    Reflection(
      title: 'O Mito do Ganho',
      content: 'A sensação de "quase ganhar" é uma armadilha cerebral. Lembre-se, o RNG é totalmente aleatório, e você não tem controle.',
      source: 'Psicoeducação',
    ),
    Reflection(
      title: 'Urge Surfing',
      content: 'Quando o impulso vier, imagine-o como uma onda. Você não precisa surfá-la. Deixe-a passar, e ela perderá a força em 15 minutos.',
      source: 'Mindfulness',
    ),
  ];
  // -----------------------

  // Simula o carregamento dos dados críticos para o Dashboard
  Future<List<Goal>> loadGoals() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _userGoals;
  }
  
  // Simula o carregamento da reflexão do dia
  Future<Reflection> loadDailyReflection() async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Retorna uma reflexão aleatória para simular o dinamismo
    final random = Random();
    return _dailyReflections[random.nextInt(_dailyReflections.length)];
  }

  /// Marca uma meta como completa
  Future<void> completeGoal(String goalId) async {
    final index = _userGoals.indexWhere((g) => g.id == goalId);
    if (index != -1 && !_userGoals[index].isCompleted) {
      _userGoals[index] = _userGoals[index].copyWith(isCompleted: true);
      // Em uma aplicação real, aqui o dado seria persistido no PostgreSQL/Backend.
      print('Meta completada: ${_userGoals[index].title}');
    }
  }
}