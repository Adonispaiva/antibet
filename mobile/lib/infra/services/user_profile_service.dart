import 'package:mobile/infra/services/auth_service.dart'; // Reutiliza o UserModel

// O UserProfileService é responsável por buscar e persistir os dados do perfil do usuário
// no Backend (Infraestrutura).
class UserProfileService {
  
  // Construtor
  UserProfileService();

  // 1. Simulação da chamada de API para buscar o perfil completo do usuário
  Future<UserModel?> fetchUserProfile() async {
    // -----------------------------------------------------------------
    // TODO: Implementar a chamada HTTP real (GET /profile)
    // -----------------------------------------------------------------
    
    // Simulação de delay de rede
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulação de dados do usuário logado (usando dados mock)
    return UserModel(
      id: 'user_123',
      name: 'Adonis Paiva',
      email: 'teste@inovexa.com',
      // Outros campos do perfil (ex: phone, avatarUrl, settings) seriam inclusos aqui
    );
  }

  // 2. Simulação da chamada de API para atualizar o perfil do usuário
  Future<UserModel?> updateUserProfile({
    required String name,
    required String email,
    // Outros parâmetros...
  }) async {
    // -----------------------------------------------------------------
    // TODO: Implementar a chamada HTTP real (PUT /profile)
    // -----------------------------------------------------------------

    // Simulação de delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Simulação de sucesso (retorna o novo modelo)
    return UserModel(
      id: 'user_123',
      name: name,
      email: email,
    );
  }

  // 3. Simulação da chamada de API para mudança de senha (separado do update de perfil)
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // -----------------------------------------------------------------
    // TODO: Implementar a chamada HTTP real para mudança de senha
    // -----------------------------------------------------------------
    
    // Simulação de sucesso
    return true;
  }
}