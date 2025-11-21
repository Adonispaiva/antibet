import 'package:antibet/core/data/api/api_client.dart';
import 'package:antibet/features/user/models/user_model.dart';
import 'package:injectable/injectable.dart'; // Usando injectable para DDD/Clean Arch

/// Define a interface para o serviço de usuário.
/// Isso permite a substituição (mocking) e a inversão de dependência.
abstract class IUserService {
  Future<UserModel> fetchCurrentUser();
  // Future<void> updateProfile(UserUpdateModel updateData); // Futuras implementações
  // Future<void> changePassword({required String oldPassword, required String newPassword}); // Futuras implementações
}

/// Implementação concreta do serviço de usuário.
/// Utiliza o ApiClient para comunicação com o Backend.
@LazySingleton(as: IUserService)
class UserService implements IUserService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  /// Busca o perfil do usuário logado na API.
  /// Lida com a deserialização do JSON para o UserModel.
  @override
  Future<UserModel> fetchCurrentUser() async {
    try {
      final response = await _apiClient.get('/user/me');
      // Assumindo que 'response.data' é o payload JSON do usuário.
      // O tratamento de erros HTTP (401, 404, 500) deve ser encapsulado no ApiClient.
      return UserModel.fromJson(response.data);
    } catch (e) {
      // Em uma aplicação real, aqui seria feito um log e/ou uma exceção específica seria relançada.
      // throw FetchUserException('Não foi possível buscar o perfil do usuário.', innerException: e);
      rethrow;
    }
  }
}