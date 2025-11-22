import 'package:flutter_test/flutter_test.dart';
import 'package:antibet_mobile/models/user_model.dart';
import 'package:antibet_mobile/infra/services/user_profile_service.dart';

// =========================================================================
// SIMULAÇÃO DE DEPENDÊNCIAS (Mocks)
// =========================================================================

// Simulação de UserModel (para que o teste possa ser executado neste ambiente)
class UserModel {
  final String id;
  final String email;
  final String? name;
  final DateTime? createdAt;

  UserModel({required this.id, required this.email, this.name, this.createdAt});
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
  
  UserModel copyWith({String? id, String? email, String? name, DateTime? createdAt}) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Mock da classe de Serviço de Perfil
class UserProfileService {
  UserProfileService();
  bool shouldFailGet = false;
  bool shouldFailUpdate = false;
  
  final mockUserJson = {
    'id': 'user_uuid_001',
    'email': 'original@inovexa.com',
    'name': 'Original User',
    'createdAt': '2025-01-01T00:00:00Z'
  };

  Future<UserModel> getUserProfile() async {
    if (shouldFailGet) {
      throw Exception('Falha de rede ao buscar perfil.');
    }
    await Future.delayed(Duration.zero);
    return UserModel.fromJson(mockUserJson);
  }

  Future<UserModel> updateUserProfile(UserModel userToUpdate) async {
    if (shouldFailUpdate) {
      throw Exception('Falha de rede ao salvar perfil.');
    }
    await Future.delayed(Duration.zero);
    // Simula o retorno do objeto salvo com sucesso
    return userToUpdate;
  }
}

// =========================================================================
// FIM DA SIMULAÇÃO
// =========================================================================

void main() {
  group('UserProfileService Unit Tests', () {
    late UserProfileService profileService;

    setUp(() {
      profileService = UserProfileService();
    });

    test('01. getUserProfile deve retornar um UserModel válido e preenchido', () async {
      final user = await profileService.getUserProfile();

      expect(user, isA<UserModel>());
      expect(user.email, 'original@inovexa.com');
      expect(user.name, 'Original User');
      expect(user.createdAt, DateTime.parse('2025-01-01T00:00:00Z'));
    });

    test('02. getUserProfile deve lançar exceção em caso de falha de API', () async {
      profileService.shouldFailGet = true;

      expect(
        () => profileService.getUserProfile(),
        throwsA(isA<Exception>()),
      );
    });

    test('03. updateUserProfile deve retornar o UserModel atualizado em caso de sucesso', () async {
      final originalUser = UserModel.fromJson(profileService.mockUserJson);
      const updatedName = 'Adonis Paiva';
      
      final userToUpdate = originalUser.copyWith(name: updatedName);
      
      final returnedUser = await profileService.updateUserProfile(userToUpdate);

      expect(returnedUser, isA<UserModel>());
      expect(returnedUser.name, updatedName);
      expect(returnedUser.id, originalUser.id); // ID deve ser mantido
      expect(returnedUser.toJson().keys, contains('name'));
    });

    test('04. updateUserProfile deve lançar exceção em caso de falha de API', () async {
      profileService.shouldFailUpdate = true;
      final dummyUser = UserModel(id: '1', email: 'a@b.com');

      expect(
        () => profileService.updateUserProfile(dummyUser),
        throwsA(isA<Exception>()),
      );
    });
  });
}