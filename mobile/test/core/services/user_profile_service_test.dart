import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:antibet/src/core/services/user_profile_service.dart';

void main() {
  // Chave de persistência principal (duplicada para o teste)
  const String userProfileKey = 'user_profile_data';
  late UserProfileService service;

  setUp(() {
    // Limpa o mock de SharedPreferences antes de cada teste
    SharedPreferences.setMockInitialValues({});
    service = UserProfileService();
  });

  group('UserProfileService - Model Serialization', () {
    test('UserProfile toJson and fromJson should be symmetrical', () {
      final profile = UserProfile(
        nickname: 'Theo',
        gender: 'Masculino',
        birthYearMonth: '1995-05',
        timeBetting: 'anos',
        concernLevel: 4,
      );

      final jsonMap = profile.toJson();
      
      // O mock do service armazena o map como String. Simula a string de saída.
      // Em testes reais, usaríamos dart:convert, mas aqui testamos a estrutura do map.
      final profileBack = UserProfile.fromJson(jsonMap); 

      expect(profileBack.nickname, equals('Theo'));
      expect(profileBack.gender, equals('Masculino'));
      expect(profileBack.birthYearMonth, equals('1995-05'));
      expect(profileBack.timeBetting, equals('anos'));
      expect(profileBack.concernLevel, equals(4));
    });
  });

  group('UserProfileService - Persistence Logic', () {
    test('saveProfile should persist data using SharedPreferences', () async {
      final profileToSave = UserProfile(nickname: 'Nara', concernLevel: 5);
      
      // O saveProfile usa toString() no Map, o que é inseguro, mas reflete o código atual.
      // Vamos simular a persistência baseada no toString() do Map.
      final expectedString = profileToSave.toJson().toString();
      
      await service.saveProfile(profileToSave);
      
      final prefs = await SharedPreferences.getInstance();
      
      // Verifica se a string esperada foi salva
      expect(prefs.getString(userProfileKey), equals(expectedString));
    });

    test('loadProfile should return empty UserProfile if no data exists', () async {
      // SharedPreferences é limpo no setUp
      final loadedProfile = await service.loadProfile();
      
      // Deve retornar o perfil vazio (default)
      expect(loadedProfile.nickname, isNull);
      expect(loadedProfile.concernLevel, isNull);
    });

    test('clearProfile should remove the data from SharedPreferences', () async {
      // 1. Prepara o mock com dados
      SharedPreferences.setMockInitialValues({
        userProfileKey: UserProfile(nickname: 'Luzia').toJson().toString(),
      });
      
      // Recria o serviço para carregar o estado inicial
      service = UserProfileService(); 
      await service.loadProfile(); // Garante que as prefs foram inicializadas

      // 2. Limpa o perfil
      await service.clearProfile();
      
      // 3. Verifica se a chave foi removida
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(userProfileKey), isFalse);
    });
  });
}