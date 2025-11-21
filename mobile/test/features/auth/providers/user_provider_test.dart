// ignore_for_file: cascade_invocations

import 'dart:convert';

import 'package.flutter_test/flutter_test.dart';
import 'package.mockito/mockito.dart';
import 'package.flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';

import 'package:antibet/features/auth/models/user_model.dart';
import 'package:antibet/features/auth/providers/user_provider.dart';
import 'package:antibet/features/auth/services/auth_service.dart';
import 'package:antibet/core/services/secure_storage_service.dart';
import 'package:antibet/core/errors/failures.dart';

// Importando os mocks gerados
import '../../../../mocks/core/services/storage_service.mocks.dart';
import '../../../../mocks/features/auth/services/auth_service.mocks.dart';

void main() {
  // Mocks
  late MockAuthService mockAuthService;
  late MockSecureStorageService mockSecureStorageService;
  late ProviderContainer container;

  // Modelos de Teste
  final tUserModel = UserModel(
    id: '1',
    name: 'Test User',
    email: 'test@example.com',
    token: 'fake-token-123',
  );
  final tUserModelString = jsonEncode(tUserModel.toJson());

  // Configuração inicial para cada teste
  setUp(() {
    mockAuthService = MockAuthService();
    mockSecureStorageService = MockSecureStorageService();

    // Criamos um ProviderContainer que sobrepõe as dependências reais
    // com os nossos mocks.
    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
        secureStorageServiceProvider.overrideWithValue(mockSecureStorageService),
      ],
    );
  });

  // Limpeza após cada teste
  tearDown(() {
    container.dispose();
  });

  // Helper para ler o estado atual do provider
  UserState stateReader() => container.read(userProvider);

  // Helper para ler o Notifier
  UserProvider notifierReader() => container.read(userProvider.notifier);

  test('UserProvider deve iniciar com UserInitial', () {
    // Assert
    expect(stateReader(), equals(UserInitial()));
  });

  group('loadUser', () {
    test(
        'deve transicionar para UserLoaded se o usuário estiver no storage e o token for válido',
        () async {
      // Arrange
      when(mockSecureStorageService.read(key: 'user'))
          .thenAnswer((_) async => tUserModelString);
      when(mockAuthService.validateToken(tUserModel.token))
          .thenAnswer((_) async => const Right(true));

      // Act
      final loadFuture = notifierReader().loadUser();

      // Assert (Verifica o estado de carregamento)
      expect(stateReader(), equals(UserLoading()));

      // Aguarda a conclusão
      await loadFuture;

      // Assert (Verifica o estado final)
      expect(stateReader(), equals(UserLoaded(user: tUserModel)));
      verify(mockSecureStorageService.read(key: 'user')).called(1);
      verify(mockAuthService.validateToken(tUserModel.token)).called(1);
    });

    test('deve transicionar para UserLoggedOut se o usuário não estiver no storage',
        () async {
      // Arrange
      when(mockSecureStorageService.read(key: 'user'))
          .thenAnswer((_) async => null);

      // Act
      final loadFuture = notifierReader().loadUser();

      // Assert (Loading)
      expect(stateReader(), equals(UserLoading()));

      // Aguarda
      await loadFuture;

      // Assert (Final)
      expect(stateReader(), equals(UserLoggedOut()));
      verify(mockSecureStorageService.read(key: 'user')).called(1);
      // Não deve tentar validar o token se não há usuário
      verifyNever(mockAuthService.validateToken(any));
    });

    test(
        'deve transicionar para UserLoggedOut se o usuário estiver no storage mas o token for inválido',
        () async {
      // Arrange
      when(mockSecureStorageService.read(key: 'user'))
          .thenAnswer((_) async => tUserModelString);
      // Mock: Token validation falha
      when(mockAuthService.validateToken(tUserModel.token))
          .thenAnswer((_) async => const Right(false));

      // Act
      final loadFuture = notifierReader().loadUser();

      // Assert (Loading)
      expect(stateReader(), equals(UserLoading()));

      // Aguarda
      await loadFuture;

      // Assert (Final)
      expect(stateReader(), equals(UserLoggedOut()));
      verify(mockSecureStorageService.read(key: 'user')).called(1);
      verify(mockAuthService.validateToken(tUserModel.token)).called(1);
    });

    test(
        'deve transicionar para UserLoggedOut se a validação do token falhar (ex: API error)',
        () async {
      // Arrange
      when(mockSecureStorageService.read(key: 'user'))
          .thenAnswer((_) async => tUserModelString);
      // Mock: API falha na validação
      when(mockAuthService.validateToken(tUserModel.token))
          .thenAnswer((_) async => Left(ApiFailure(message: 'API Error')));

      // Act
      final loadFuture = notifierReader().loadUser();

      // Assert (Loading)
      expect(stateReader(), equals(UserLoading()));

      // Aguarda
      await loadFuture;

      // Assert (Final)
      expect(stateReader(), equals(UserLoggedOut()));
    });
  });

  group('login', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';

    test('deve transicionar para UserLoaded e salvar no storage em caso de sucesso',
        () async {
      // Arrange
      when(mockAuthService.login(tEmail, tPassword))
          .thenAnswer((_) async => Right(tUserModel));
      when(mockSecureStorageService.write(
              key: 'user', value: tUserModelString))
          .thenAnswer((_) async => _); // Mock de sucesso (void)

      // Act
      final loginFuture = notifierReader().login(tEmail, tPassword);

      // Assert (Loading)
      expect(stateReader(), equals(UserLoading()));

      // Aguarda
      await loginFuture;

      // Assert (Final)
      expect(stateReader(), equals(UserLoaded(user: tUserModel)));
      // Verifica se o login foi chamado
      verify(mockAuthService.login(tEmail, tPassword)).called(1);
      // Verifica se o usuário foi salvo no storage
      verify(mockSecureStorageService.write(
              key: 'user', value: tUserModelString))
          .called(1);
    });

    test('deve transicionar para UserError em caso de falha na autenticação',
        () async {
      // Arrange
      final tFailure = AuthFailure(message: 'Credenciais inválidas');
      when(mockAuthService.login(tEmail, tPassword))
          .thenAnswer((_) async => Left(tFailure));

      // Act
      final loginFuture = notifierReader().login(tEmail, tPassword);

      // Assert (Loading)
      expect(stateReader(), equals(UserLoading()));

      // Aguarda
      await loginFuture;

      // Assert (Final)
      expect(stateReader(), equals(UserError(message: tFailure.message)));
      // Verifica se o login foi chamado
      verify(mockAuthService.login(tEmail, tPassword)).called(1);
      // Não deve salvar nada no storage
      verifyNever(mockSecureStorageService.write(key: 'user', value: any));
    });
  });

  group('logout', () {
    test('deve transicionar para UserLoggedOut e limpar o storage', () async {
      // Arrange
      // Simula um estado logado inicial
      container.read(userProvider.notifier).state = UserLoaded(user: tUserModel);
      
      when(mockSecureStorageService.delete(key: 'user'))
          .thenAnswer((_) async => _); // Mock de sucesso (void)

      // Act
      final logoutFuture = notifierReader().logout();

      // Assert (Loading)
      expect(stateReader(), equals(UserLoading()));

      // Aguarda
      await logoutFuture;

      // Assert (Final)
      expect(stateReader(), equals(UserLoggedOut()));
      // Verifica se o storage foi limpo
      verify(mockSecureStorageService.delete(key: 'user')).called(1);
    });
  });
}