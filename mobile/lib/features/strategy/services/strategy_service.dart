import 'package:antibet/core/data/api/api_client.dart';
// Será necessário criar o StrategyModel
import 'package:antibet/features/strategy/models/strategy_model.dart'; 
import 'package:injectable/injectable.dart';

/// Define a interface para o serviço de gestão de Estratégias de Trading (Strategy).
abstract class IStrategyService {
  /// Busca todas as estratégias de trading criadas pelo usuário.
  Future<List<StrategyModel>> fetchStrategies();

  /// Cria uma nova estratégia.
  Future<StrategyModel> createStrategy(StrategyModel strategy);

  /// Atualiza uma estratégia existente.
  Future<StrategyModel> updateStrategy(StrategyModel strategy);

  /// Deleta uma estratégia pelo seu ID.
  Future<void> deleteStrategy(String id);
}

/// Implementação concreta do serviço Strategy.
/// Utiliza o ApiClient para comunicação com os endpoints do módulo Strategy do Backend.
@LazySingleton(as: IStrategyService)
class StrategyService implements IStrategyService {
  final ApiClient _apiClient;

  StrategyService(this._apiClient);

  @override
  Future<List<StrategyModel>> fetchStrategies() async {
    // Endpoint: GET /strategy
    final response = await _apiClient.get('/strategy');

    // Mapeia a lista de JSONs retornada para uma lista de StrategyModel
    return (response.data as List)
        .map((json) => StrategyModel.fromJson(json))
        .toList();
  }

  @override
  Future<StrategyModel> createStrategy(StrategyModel strategy) async {
    // Endpoint: POST /strategy
    final response = await _apiClient.post('/strategy', data: strategy.toJson());
    return StrategyModel.fromJson(response.data);
  }

  @override
  Future<StrategyModel> updateStrategy(StrategyModel strategy) async {
    // Endpoint: PUT /strategy/:id
    final response = await _apiClient.put('/strategy/${strategy.id}', data: strategy.toJson());
    return StrategyModel.fromJson(response.data);
  }

  @override
  Future<void> deleteStrategy(String id) async {
    // Endpoint: DELETE /strategy/:id
    await _apiClient.delete('/strategy/$id');
  }
}