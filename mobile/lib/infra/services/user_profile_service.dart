import 'package:antibet_mobile/models/user_model.dart';
import 'package:flutter/material.dart';
// Opcional: pode precisar do StorageService se o ID do usuário não for passado
// import 'package:antibet_mobile/infra/services/storage_service.dart';

/// Camada de Serviço de Infraestrutura para o Perfil do Usuário.
///
/// Responsável pela lógica de negócios e comunicação com a API (Backend)
/// referente aos dados do perfil do usuário (leitura e atualização).
class UserProfileService {
  // Simulação de dependência de um cliente HTTP (ex: Dio, Http)
  // final ApiClient _apiClient;
  // final StorageService _storageService;

  // UserProfileService(this._apiClient, this._storageService);

  UserProfileService() {
    // Construtor vazio por enquanto
  }

  /// Busca os dados completos do perfil do usuário logado.
  /// Presume-se que a API use o token (enviado pelo ApiClient) para identificar o usuário.
  Future<UserModel> getUserProfile() async {
    try {
      // 1. Simulação de chamada de rede (API call)
      debugPrint('[UserProfileService] Buscando perfil do usuário...');
      await Future.delayed(const Duration(milliseconds: 600));

      // 2. Simulação de resposta da API (JSON)
      // (Em um caso real, o AuthService.login pode não retornar todos os dados)
      final mockApiResponse = {
        'id': 'user_uuid_001',
        'email': 'adonis@inovexa.com',
        'name': 'Adonis Paiva (Dados Completos)',
        'createdAt': '2025-11-01T10:00:00Z'
        // 'subscriptionStatus': 'active',
        // 'avatarUrl': '...'
      };

      // 3. Parsear e retornar o UserModel
      final user = UserModel.fromJson(mockApiResponse);
      debugPrint('[UserProfileService] Perfil recebido: ${user.name}');
      return user;

    } catch (e) {
      debugPrint('[UserProfileService] Erro ao buscar perfil: $e');
      throw Exception('Falha ao carregar dados do perfil.');
    }
  }

  /// Atualiza os dados do perfil do usuário.
  /// Retorna o [UserModel] atualizado.
  Future<UserModel> updateUserProfile(UserModel userToUpdate) async {
    try {
      // 1. Serializar os dados para enviar à API
      final Map<String, dynamic> requestBody = userToUpdate.toJson();

      // 2. Simulação de chamada de rede (API call - PUT/PATCH)
      debugPrint('[UserProfileService] Atualizando perfil: $requestBody');
      await Future.delayed(const Duration(milliseconds: 750));

      // 3. Simulação de resposta da API (retorna o objeto atualizado)
      final mockApiResponse = requestBody; 
      // A API normalmente confirmaria os dados ou adicionaria campos (ex: updatedAt)
      
      // 4. Parsear e retornar o UserModel atualizado
      final updatedUser = UserModel.fromJson(mockApiResponse);
      debugPrint('[UserProfileService] Perfil atualizado com sucesso.');
      return updatedUser;

    } catch (e) {
      debugPrint('[UserProfileService] Erro ao atualizar perfil: $e');
      throw Exception('Falha ao salvar dados do perfil.');
    }
  }
}