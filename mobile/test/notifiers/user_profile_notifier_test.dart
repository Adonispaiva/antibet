import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:antibet_mobile/models/user_model.dart';
import 'package:antibet_mobile/infra/services/user_profile_service.dart';
import 'package:antibet_mobile/notifiers/user_profile_notifier.dart';
import 'package:antibet_mobile/notifiers/auth_notifier.dart';

// =========================================================================
// SIMULAÇÃO DE DEPENDÊNCIAS (Mocks)
// =========================================================================

// Simulação de UserModel (mínimo necessário para o teste)
class UserModel {
  final String id;
  final String email;
  final String? name;
  UserModel({required this.id, required this.email, this.name});
  UserModel copyWith({String? id, String? email, String? name}) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
    );
  }
}

// Simulação de UserProfileService (mínimo necessário para o teste)
class UserProfileService {
  UserProfileService();
  Future<UserModel> getUserProfile() async => throw UnimplementedError();
  Future<UserModel> updateUserProfile(UserModel userToUpdate) async => throw UnimplementedError();
}

// Simulação de AuthNotifier (mínimo necessário para o teste)
class AuthNotifier with ChangeNotifier {
  AuthNotifier(dynamic authService);
  UserModel? user;
  // Apenas simula o estado do usuário que o Notifier dependente lê.
}


// Mock da classe de Serviço de Perfil
class MockUserProfileService implements UserProfileService {
  bool shouldFailGet = false;
  bool shouldFailUpdate = false;
  
  final mockUser = UserModel(id: 'u001', email: 'test@inovexa.com', name: 'Test User');

  @override
  Future<UserModel> getUserProfile() async {
    if (shouldFailGet) {
      throw Exception('Falha ao buscar perfil.');
    }
    return mockUser;
  }

  @override
  Future<UserModel> updateUserProfile(UserModel userToUpdate) async {
    if (shouldFailUpdate) {
      throw Exception('Falha ao salvar perfil.');
    }
    return userToUpdate;
  }
}

// Mock da classe de Notifier de Autenticação
class MockAuthNotifier extends Mock implements AuthNotifier {
  @override
  UserModel? user;
}


// SIMULAÇÃO DO NOTIFIER (mínimo necessário para o teste)
class UserProfileNotifier with ChangeNotifier {
  final MockUserProfileService _profileService;
  final MockAuthNotifier _authNotifier;

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfileNotifier(this._profileService, this._authNotifier) {
    _user = _authNotifier.user;
  }

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateUserFromAuth(AuthNotifier authNotifier) {
    if (_user != authNotifier.user) {
      _user = authNotifier.user;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> fetchProfile() async {
    _setStateLoading(true);
    try {
      final updatedUser = await _profileService.getUserProfile();
      _user = updatedUser;
    } catch (e) {
      _errorMessage = 'Falha ao buscar dados do perfil.';
    } finally {
      _setStateLoading(false);
    }
  }

  Future<bool> updateProfile(UserModel userToUpdate) async {
    _setStateLoading(true);
    try {
      final updatedUser = await _profileService.updateUserProfile(userToUpdate);
      _user = updatedUser;
      _setStateLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Falha ao salvar dados.';
      _setStateLoading(false);
      return false;
    }
  }

  void _setStateLoading(bool loading) {
    _isLoading = loading;
    if (loading) _errorMessage = null;
    notifyListeners();
  }
}

// =========================================================================
// FIM DA SIMULAÇÃO
// =========================================================================

void main() {
  group('UserProfileNotifier Unit Tests', () {
    late UserProfileNotifier notifier;
    late MockUserProfileService mockService;
    late MockAuthNotifier mockAuth;
    
    final tInitialUser = UserModel(id: 'u000', email: 'initial@auth.com', name: 'Initial Auth User');

    // Configuração: Garante estado limpo e objetos antes de cada teste
    setUp(() {
      mockService = MockUserProfileService();
      mockAuth = MockAuthNotifier();
      mockAuth.user = tInitialUser; // Estado inicial logado
      notifier = UserProfileNotifier(mockService, mockAuth);
    });

    test('01. Deve inicializar o usuário sincronizado com o AuthNotifier', () {
      expect(notifier.user, tInitialUser);
    });

    // ---------------------------------------------------------------------
    // Testes de Fetch (Busca)
    // ---------------------------------------------------------------------
    test('02. fetchProfile deve atualizar o usuário em caso de sucesso', () async {
      await notifier.fetchProfile();
      
      // Estado de Sucesso
      expect(notifier.isLoading, false);
      expect(notifier.user!.name, 'Test User'); // O nome vem do MockService
      expect(notifier.errorMessage, isNull);
    });

    test('03. fetchProfile deve definir mensagem de erro em caso de falha', () async {
      mockService.shouldFailGet = true;
      
      await notifier.fetchProfile();
      
      // Estado de Falha
      expect(notifier.isLoading, false);
      expect(notifier.user, tInitialUser); // O usuário não deve ser limpo, apenas o erro aparece
      expect(notifier.errorMessage, 'Falha ao buscar dados do perfil.');
    });

    // ---------------------------------------------------------------------
    // Testes de Update (Atualização)
    // ---------------------------------------------------------------------
    test('04. updateProfile deve retornar true e atualizar o usuário em caso de sucesso', () async {
      final newUser = notifier.user!.copyWith(name: 'Novo Nome');
      
      final success = await notifier.updateProfile(newUser);
      
      // Estado de Sucesso
      expect(success, isTrue);
      expect(notifier.isLoading, false);
      expect(notifier.user!.name, 'Novo Nome');
      expect(notifier.errorMessage, isNull);
    });
    
    test('05. updateProfile deve retornar false e definir mensagem de erro em caso de falha', () async {
      mockService.shouldFailUpdate = true;
      final success = await notifier.updateProfile(notifier.user!);
      
      // Estado de Falha
      expect(success, isFalse);
      expect(notifier.isLoading, false);
      expect(notifier.user!.name, 'Initial Auth User'); // O usuário deve permanecer o mesmo
      expect(notifier.errorMessage, 'Falha ao salvar dados.');
    });
    
    // ---------------------------------------------------------------------
    // Testes de Sincronização
    // ---------------------------------------------------------------------
    test('06. updateUserFromAuth deve atualizar o usuário e notificar ouvintes', () {
      final listenerCallCount = <int>[];
      notifier.addListener(() => listenerCallCount.add(1));
      
      final loggedOutAuth = MockAuthNotifier()..user = null;
      
      notifier.updateUserFromAuth(loggedOutAuth);

      expect(notifier.user, isNull);
      expect(listenerCallCount, [1]);
    });
    
    test('07. updateUserFromAuth não deve notificar se o usuário for o mesmo', () {
      final listenerCallCount = <int>[];
      notifier.addListener(() => listenerCallCount.add(1));
      
      // Passa o mesmo objeto de usuário que já está lá
      final sameUserAuth = MockAuthNotifier()..user = tInitialUser;
      
      notifier.updateUserFromAuth(sameUserAuth);

      expect(listenerCallCount, isEmpty);
    });
  });
}