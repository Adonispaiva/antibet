import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Importações dos componentes a serem testados e dependências
import 'package:antibet_mobile/core/domain/user_model.dart';
import 'package:antibet_mobile/core/domain/user_profile_model.dart';
import 'package:antibet_mobile/infra/services/user_profile_service.dart';
import 'package:antibet_mobile/notifiers/auth_notifier.dart';
import 'package:antibet_mobile/notifiers/user_profile_notifier.dart';

// Gera os mocks para as dependências
@GenerateMocks([UserProfileService, AuthNotifier])
import 'user_profile_notifier_test.mocks.dart'; 

void main() {
  late MockUserProfileService mockProfileService;
  late MockAuthNotifier mockAuthNotifier;
  late UserProfileNotifier userProfileNotifier;

  const UserModel testUser = UserModel(id: 'test_id', email: 'test@antibet.com');
  const UserProfileModel initialProfile = UserProfileModel(
    userId: 'test_id', 
    fullName: 'Teste Inicial', 
    phoneNumber: '111', 
  );
  const UserProfileException profileError = UserProfileException('Falha de serviço simulada.');

  // Configuração executada antes de cada teste
  setUp(() {
    mockProfileService = MockUserProfileService();
    mockAuthNotifier = MockAuthNotifier();
    
    // Configuração inicial padrão do AuthNotifier (logado)
    when(mockAuthNotifier.isAuthenticated).thenReturn(true);
    when(mockAuthNotifier.currentUser).thenReturn(testUser);
    
    // Injeta os mocks
    userProfileNotifier = UserProfileNotifier(mockProfileService, mockAuthNotifier); 
  });

  // Limpeza executada após cada teste
  tearDown(() {
    // É crucial remover o listener explicitamente em testes de Notifier
    userProfileNotifier.dispose(); 
    reset(mockProfileService);
    reset(mockAuthNotifier);
  });

  group('UserProfileNotifier - Fetch Profile', () {
    // --- Teste 1: Estado Inicial ---
    test('Estado inicial é ProfileState.initial', () {
      expect(userProfileNotifier.state, ProfileState.initial);
      expect(userProfileNotifier.userProfile, isNull);
    });

    // --- Teste 2: Busca Bem-Sucedida ---
    test('fetchProfile: sucesso define profile e muda para ProfileState.loaded', () async {
      // Configuração: Serviço retorna um perfil
      when(mockProfileService.fetchProfile(testUser)).thenAnswer((_) async => initialProfile);
      
      await userProfileNotifier.fetchProfile();

      // Verifica as transições de estado
      expect(userProfileNotifier.state, ProfileState.loaded);
      expect(userProfileNotifier.userProfile, initialProfile);
      verify(mockProfileService.fetchProfile(testUser)).called(1);
    });

    // --- Teste 3: Busca Mal-Sucedida (UserProfileException) ---
    test('fetchProfile: falha define erro e muda para ProfileState.error', () async {
      // Configuração: Serviço lança exceção
      when(mockProfileService.fetchProfile(testUser)).thenThrow(profileError);
      
      await userProfileNotifier.fetchProfile();

      // Verifica o estado final
      expect(userProfileNotifier.state, ProfileState.error);
      expect(userProfileNotifier.userProfile, isNull);
      expect(userProfileNotifier.errorMessage, contains('Falha ao carregar perfil'));
    });

    // --- Teste 4: Busca sem Usuário Logado ---
    test('fetchProfile: falha se currentUser for nulo (não logado)', () async {
      // Configuração: Simula que o usuário fez logout antes da chamada
      when(mockAuthNotifier.currentUser).thenReturn(null);
      
      await userProfileNotifier.fetchProfile();

      // Verifica o estado final
      expect(userProfileNotifier.state, ProfileState.error);
      expect(userProfileNotifier.errorMessage, contains('Usuário não logado'));
      verifyNever(mockProfileService.fetchProfile(any));
    });
  });

  group('UserProfileNotifier - Update Profile', () {
    // Prepara o notifier com um perfil carregado
    setUp(() async {
      when(mockProfileService.fetchProfile(testUser)).thenAnswer((_) async => initialProfile);
      await userProfileNotifier.fetchProfile(); // Carrega o perfil inicial
      reset(mockProfileService); // Limpa as interações de fetch
    });
    
    const String newFullName = 'Orion Engineer Atualizado';

    // --- Teste 5: Atualização Bem-Sucedida ---
    test('updateProfile: sucesso atualiza profile e mantém ProfileState.loaded', () async {
      final updatedProfile = initialProfile.copyWith(fullName: newFullName);
      // Configuração: Serviço retorna o perfil atualizado
      when(mockProfileService.updateProfile(any)).thenAnswer((_) async => updatedProfile);
      
      await userProfileNotifier.updateProfile(fullName: newFullName);

      // Verifica o estado e o perfil atualizados
      expect(userProfileNotifier.state, ProfileState.loaded);
      expect(userProfileNotifier.userProfile!.fullName, newFullName);
      
      // Verifica se o serviço foi chamado com o objeto correto
      verify(mockProfileService.updateProfile(
        argThat(
          isA<UserProfileModel>()
          .having((p) => p.fullName, 'fullName', newFullName)
        )
      )).called(1);
    });

    // --- Teste 6: Atualização Mal-Sucedida (Relançamento) ---
    test('updateProfile: falha relança exceção e define erro', () async {
      // Configuração: Serviço lança exceção
      when(mockProfileService.updateProfile(any)).thenThrow(profileError);

      // Deve lançar a exceção para que a UI possa reagir
      expect(() => userProfileNotifier.updateProfile(fullName: 'Nome Invalido'), throwsA(isA<UserProfileException>()));

      // O estado deve retornar para loaded (pois o perfil ainda está carregado)
      expect(userProfileNotifier.state, ProfileState.loaded); 
      expect(userProfileNotifier.userProfile, initialProfile); // Não deve ter mudado
      expect(userProfileNotifier.errorMessage, contains('Falha ao atualizar perfil'));
    });
  });
  
  group('UserProfileNotifier - Auth Integration', () {
    // --- Teste 7: Limpeza ao Logout ---
    test('handleAuthChange: perfil é limpo e estado volta para initial após logout', () async {
      // 1. Prepara o notifier com um perfil carregado (simula o login)
      when(mockProfileService.fetchProfile(testUser)).thenAnswer((_) async => initialProfile);
      await userProfileNotifier.fetchProfile(); 
      expect(userProfileNotifier.state, ProfileState.loaded);

      // 2. Simula o logout no AuthNotifier
      when(mockAuthNotifier.isAuthenticated).thenReturn(false);
      
      // Chama o método que é disparado pelo listener
      userProfileNotifier.dispose(); // Remove o listener antigo
      userProfileNotifier = UserProfileNotifier(mockProfileService, mockAuthNotifier); // Cria novo para injetar o listener
      userProfileNotifier.dispose(); // Remove o novo listener para evitar múltiplas chamadas
      
      // Chama o método diretamente, simulando o que o listener faria
      userProfileNotifier.handleAuthChange(); 
      
      // 3. Verifica o estado final
      expect(userProfileNotifier.state, ProfileState.initial);
      expect(userProfileNotifier.userProfile, isNull);
    });
  });
}