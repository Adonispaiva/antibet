import 'package:flutter_test/flutter_test.dart';

// Importações dos componentes a serem testados e dependências
import 'package:antibet_mobile/core/domain/user_model.dart';
import 'package:antibet_mobile/core/domain/user_profile_model.dart';
import 'package:antibet_mobile/infra/services/user_profile_service.dart';

void main() {
  late UserProfileService profileService;
  
  // Usuário de teste válido (ID 123 é o ID de sucesso na simulação do service)
  const UserModel validUser = UserModel(id: '123', email: 'test@inovexa.com.br');
  const UserModel guestUser = UserModel(id: 'guest', email: 'guest@antibet.com');
  
  // Setup executado antes de cada teste
  setUp(() {
    // Instancia o serviço para isolar o cache
    profileService = UserProfileService(); 
  });

  group('UserProfileService - Fetch Profile', () {
    // --- Teste 1: Busca Bem-Sucedida (Simulação) ---
    test('fetchProfile deve retornar um UserProfileModel para um usuário válido', () async {
      final profile = await profileService.fetchProfile(validUser);

      // Verifica o tipo e a consistência básica dos dados simulados
      expect(profile, isA<UserProfileModel>());
      expect(profile.userId, validUser.id);
      expect(profile.fullName, isNotEmpty);
    });

    // --- Teste 2: Busca com Usuário Convidado ---
    test('fetchProfile deve lançar UserProfileException para usuário convidado', () async {
      expect(
        () => profileService.fetchProfile(guestUser), 
        throwsA(isA<UserProfileException>()),
      );
    });

    // --- Teste 3: Lógica de Caching Simulada ---
    test('fetchProfile deve retornar o perfil em cache na segunda chamada', () async {
      // 1. Primeira busca (cria o cache)
      final profile1 = await profileService.fetchProfile(validUser);
      
      // 2. Segunda busca
      final profile2 = await profileService.fetchProfile(validUser);

      // Verifica se os objetos são o mesmo (ou se o conteúdo é o mesmo, dependendo da simulação)
      // Como o service simula cache retornando _cachedProfile, esperamos o mesmo valor.
      expect(profile2.fullName, profile1.fullName); 
    });
  });

  group('UserProfileService - Update Profile', () {
    // Prepara o serviço com um perfil para ser atualizado
    late UserProfileModel initialProfile;
    setUp(() async {
      initialProfile = await profileService.fetchProfile(validUser);
    });

    // --- Teste 4: Atualização Bem-Sucedida ---
    test('updateProfile deve retornar o perfil atualizado e atualizar o cache', () async {
      const newName = 'Novo Nome Atualizado';
      final updatedProfile = initialProfile.copyWith(
        fullName: newName,
      );

      final result = await profileService.updateProfile(updatedProfile);

      // Verifica se o valor retornado é o novo nome
      expect(result.fullName, newName);
      
      // Verifica se o cache foi atualizado
      final cachedProfile = await profileService.fetchProfile(validUser);
      expect(cachedProfile.fullName, newName);
    });

    // --- Teste 5: Atualização Mal-Sucedida (Nome Vazio) ---
    test('updateProfile deve lançar UserProfileException se o nome for vazio', () async {
      final invalidProfile = initialProfile.copyWith(
        fullName: '', // Lógica de falha simulada no service
      );
      
      expect(
        () => profileService.updateProfile(invalidProfile), 
        throwsA(isA<UserProfileException>()),
      );
      
      // Verifica se o cache NÃO foi alterado
      final cachedProfile = await profileService.fetchProfile(validUser);
      expect(cachedProfile.fullName, isNotEmpty);
    });
    
    // --- Teste 6: Atualização Mal-Sucedida (Erro Desconhecido Simulado) ---
    test('updateProfile deve lançar exceção se o ID não for 123', () async {
      const UserModel otherUser = UserModel(id: '999', email: 'other@test.com');
      final otherProfile = initialProfile.copyWith(
        userId: otherUser.id, // Simula um ID que causa falha na simulação
      );

      expect(
        () => profileService.updateProfile(otherProfile), 
        throwsA(isA<UserProfileException>()),
      );
    });
  });
}