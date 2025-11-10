import 'dart:async';
import 'package:flutter/foundation.dart';

// Importação do modelo de Domínio
import '../../core/domain/user_profile_model.dart';
import '../../core/domain/user_model.dart'; // Necessário para linkar o perfil ao usuário logado

/// Classe de exceção personalizada para falhas na operação de Perfil.
class UserProfileException implements Exception {
  final String message;
  UserProfileException(this.message);

  @override
  String toString() => 'UserProfileException: $message';
}

/// O serviço de Perfil é responsável pela comunicação com a API (simulada) para 
/// buscar e atualizar os dados do usuário.
class UserProfileService {
  // Simulação de cache ou persistência local do perfil
  UserProfileModel? _cachedProfile; 

  // Dependência do AuthService seria injetada aqui para obter o ID do usuário,
  // mas faremos a simulação direta por enquanto.

  UserProfileService();

  /// Simula a busca do perfil na API.
  Future<UserProfileModel> fetchProfile(UserModel user) async {
    // Simulação de delay de rede
    await Future.delayed(const Duration(milliseconds: 500));

    if (user.id == 'guest') {
       throw UserProfileException('Usuário convidado não possui perfil detalhado.');
    }
    
    if (_cachedProfile != null && _cachedProfile!.userId == user.id) {
      // Retorna o cache se o ID for o mesmo
      return _cachedProfile!;
    }
    
    // --- SIMULAÇÃO DE LÓGICA DE API (Busca) ---
    try {
      // Cria um perfil fictício baseado no usuário logado
      final fetchedProfile = UserProfileModel(
        userId: user.id,
        fullName: 'Orion Software Engineer',
        phoneNumber: '11987654321',
        dateOfBirth: DateTime(1990, 1, 1),
      );
      _cachedProfile = fetchedProfile;
      return fetchedProfile;
      
    } catch (e) {
      throw UserProfileException('Falha ao buscar o perfil na infraestrutura.');
    }
  }

  /// Simula a atualização do perfil na API.
  Future<UserProfileModel> updateProfile(UserProfileModel profile) async {
    // Simulação de delay de rede
    await Future.delayed(const Duration(milliseconds: 500));

    // --- SIMULAÇÃO DE LÓGICA DE API (Atualização) ---
    if (profile.fullName.isEmpty) {
      throw UserProfileException('O nome completo não pode estar vazio.');
    }
    
    if (profile.userId == '123') { // Simulação de sucesso
      _cachedProfile = profile;
      return profile;
    } else {
      throw UserProfileException('Erro desconhecido ao salvar o perfil.');
    }
  }
}