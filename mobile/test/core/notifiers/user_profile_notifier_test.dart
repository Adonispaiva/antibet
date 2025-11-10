import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:antibet/src/core/services/user_profile_service.dart';
import 'package:antibet/src/core/notifiers/user_profile_notifier.dart';
import 'package:antibet/src/core/notifiers/auth_notifier.dart';

// Mocks
class MockUserProfileService extends Mock implements UserProfileService {
  @override
  Future<UserProfile> loadProfile() => super.noSuchMethod(
        Invocation.method(#loadProfile, []),
        returnValue: Future.value(UserProfile()),
      ) as Future<UserProfile>;
  
  @override
  Future<void> saveProfile(UserProfile profile) => super.noSuchMethod(
        Invocation.method(#saveProfile, [profile]),
        returnValue: Future.value(null),
      ) as Future<void>;
}

class MockAuthNotifier extends Mock implements AuthNotifier {
  @override
  bool get isLoggedIn => super.noSuchMethod(
        Invocation.getter(#isLoggedIn),
        returnValue: false,
      ) as bool;
  
  // Mock para simular o ChangeNotifier
  @override
  void addListener(VoidCallback listener) => super.noSuchMethod(Invocation.method(#addListener, [listener]), returnValue: null);
  @override
  void removeListener(VoidCallback listener) => super.noSuchMethod(Invocation.method(#removeListener, [listener]), returnValue: null);
}

void main() {
  late MockUserProfileService mockService;
  late MockAuthNotifier mockAuthNotifier;
  late UserProfileNotifier notifier;

  setUp(() {
    mockService = MockUserProfileService();
    mockAuthNotifier = MockAuthNotifier();
    
    // Configura o AuthNotifier para simular o estado inicial (não logado)
    when(mockAuthNotifier.isLoggedIn).thenReturn(false);

    // O construtor do Notifier depende do AuthNotifier, mas não chama loadProfile
    // se isLoggedIn for false (que é o padrão).
    notifier = UserProfileNotifier(mockService, mockAuthNotifier);
  });
  
  tearDown(() {
    // Garante que o listener seja removido após o teste
    notifier.dispose();
  });

  group('UserProfileNotifier - Initialization and Auth Dependency', () {
    test('Should not call loadProfile on initialization if not logged in', () {
      verifyNever(mockService.loadProfile());
      expect(notifier.nickname, equals('Usuário(a)'));
    });

    test('Should call loadProfile when Auth status changes to Logged In', () async {
      // Simula o login (o listener no Notifier deve ser chamado)
      when(mockAuthNotifier.isLoggedIn).thenReturn(true);
      when(mockService.loadProfile()).thenAnswer((_) => Future.value(
          UserProfile(nickname: 'Theo', gender: 'Masculino')
      ));

      // Dispara o listener que o Notifier adicionou
      verify(mockAuthNotifier.addListener(any)).called(1);
      
      // Simulação de notificação de login
      notifier.addListener(() {}); // Adiciona um listener dummy
      notifier.notifyListeners(); 

      await Future.microtask(() {}); // Permite o Future do loadProfile finalizar
      
      // Verifica se o loadProfile foi chamado
      verify(mockService.loadProfile()).called(1);
      expect(notifier.nickname, equals('Theo'));
    });
  });

  group('UserProfileNotifier - Data Handling and Customization', () {
    test('updateProfile should save data and notify listeners', () async {
      final listener = MockListener();
      notifier.addListener(listener);
      
      final newProfile = UserProfile(nickname: 'Luzia', concernLevel: 3);

      await notifier.updateProfile(newProfile);
      
      // 1. Verifica se o Service foi chamado para salvar
      verify(mockService.saveProfile(newProfile)).called(1);

      // 2. Verifica se o estado local foi atualizado
      expect(notifier.profile.nickname, equals('Luzia'));
      expect(notifier.profile.concernLevel, equals(3));
      
      // 3. Verifica se os listeners foram notificados
      verify(listener()).called(1);
      
      notifier.removeListener(listener);
    });
    
    test('age getter should calculate age correctly', () {
      // Data atual: Nov 2025 (para cálculo)
      
      // Perfil de 1995 (30 anos)
      final profile30 = UserProfile(birthYearMonth: '1995-05');
      (notifier as dynamic)._profile = profile30; 
      expect(notifier.age, equals(30)); 
      
      // Perfil de 2005 (20 anos)
      final profile20 = UserProfile(birthYearMonth: '2005-01');
      (notifier as dynamic)._profile = profile20; 
      expect(notifier.age, equals(20)); 

      // Perfil com formato inválido (deve retornar 0)
      final profileInvalid = UserProfile(birthYearMonth: 'invalid');
      (notifier as dynamic)._profile = profileInvalid; 
      expect(notifier.age, equals(0)); 
    });

    test('gender and nickname getters should return defaults if null', () {
      // Perfil vazio (default)
      expect(notifier.nickname, equals('Usuário(a)'));
      expect(notifier.gender, equals('Não Informado'));
      
      // Perfil com dados
      final profileData = UserProfile(nickname: 'Nara', gender: 'Feminino');
      (notifier as dynamic)._profile = profileData; 
      expect(notifier.nickname, equals('Nara'));
      expect(notifier.gender, equals('Feminino'));
    });
  });
}

// Helper para testar se notifyListeners foi chamado
class MockListener extends Mock {
  void call();
}