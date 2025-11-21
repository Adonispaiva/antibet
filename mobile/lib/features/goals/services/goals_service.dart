import 'package:antibet/core/data/api/api_client.dart';
// Será necessário criar o GoalModel
import 'package:antibet/features/goals/models/goal_model.dart';
import 'package:injectable/injectable.dart';

/// Define a interface para o serviço de gestão de Metas (Goals).
abstract class IGoalsService {
  /// Busca todas as metas definidas pelo usuário.
  Future<List<GoalModel>> fetchGoals();

  /// Cria uma nova meta.
  Future<GoalModel> createGoal(GoalModel goal);

  /// Atualiza uma meta existente.
  Future<GoalModel> updateGoal(GoalModel goal);

  /// Deleta uma meta pelo seu ID.
  Future<void> deleteGoal(String id);
}

/// Implementação concreta do serviço Goals.
/// Utiliza o ApiClient para comunicação com os endpoints do módulo Goals do Backend.
@LazySingleton(as: IGoalsService)
class GoalsService implements IGoalsService {
  final ApiClient _apiClient;

  GoalsService(this._apiClient);

  @override
  Future<List<GoalModel>> fetchGoals() async {
    // Endpoint: GET /goals
    final response = await _apiClient.get('/goals');

    // Mapeia a lista de JSONs retornada para uma lista de GoalModel
    return (response.data as List)
        .map((json) => GoalModel.fromJson(json))
        .toList();
  }

  @override
  Future<GoalModel> createGoal(GoalModel goal) async {
    // Endpoint: POST /goals
    final response = await _apiClient.post('/goals', data: goal.toJson());
    return GoalModel.fromJson(response.data);
  }

  @override
  Future<GoalModel> updateGoal(GoalModel goal) async {
    // Endpoint: PUT /goals/:id
    final response = await _apiClient.put('/goals/${goal.id}', data: goal.toJson());
    return GoalModel.fromJson(response.data);
  }

  @override
  Future<void> deleteGoal(String id) async {
    // Endpoint: DELETE /goals/:id
    await _apiClient.delete('/goals/$id');
  }
}