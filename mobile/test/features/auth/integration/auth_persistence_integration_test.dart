import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:antibet/core/network/dio_provider.dart';
import 'package:antibet/core/local_storage/storage_service.dart';
import 'package:antibet/features/auth/data/services/auth_service.dart';
import 'package:antibet/features/auth/presentation/providers/auth_provider.dart';
import 'package:dio/dio.dart';

// Mocks
class MockDio extends Mock implements Dio {}
class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService mockAuthService;
  late ProviderContainer container;

  setUp(() {
    mockAuthService = MockAuthService();
    
    // Configuração inicial para o SharedPreferences (necessário para o StorageService)
    // O valor inicial do token será nulo, simulando o primeiro carregamento
    SharedPreferences.setMockInitialValues({});
    
    // Sobrescreve o DioProvider e o AuthService (para isolar a chamada de API real)
    container = ProviderContainer(
      overrides: [
        // Sobrescreve o dioProvider para evitar chamadas de rede reais
        dioProvider.overrideWithValue(MockDio()),
        // Sobrescreve o authServiceProvider para simular sucesso/falha de login
        authServiceProvider.overrideWithValue(mockAuthService),
      ],
    );

    registerFallbackValue('any_email');
    registerFallbackValue('any_password');
    registerFallbackValue('auth_token');
  });

  tearDown(() {
    container.dispose();
  });

  group('Auth Persistence Integration Test (Fase III)', () {
    const tEmail = 'test@persist.com';
    const tPassword = 'Password123';
    const tToken = 'persistent_jwt_token_456';

    test('should load persisted token on initialization if available', () async {
      // Arrange
      // Simula que o token já está no armazenamento local antes de o app carregar
      SharedPreferences.setMockInitialValues({'auth_token': tToken});
      
      // Cria um novo container para simular a reinicialização do app
      final containerWithToken = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(MockDio()),
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );
      
      // Força a inicialização assíncrona do StorageService
      await containerWithToken.read(sharedPreferencesProvider.future);
      
      // Act
      final authState = containerWithToken.read(authProvider);

      // Assert
      expect(authState.isAuthenticated, true);
      expect(authState.token, tToken);
      
      containerWithToken.dispose();
    });

    test('should persist token after successful login', () async {
      // Arrange
      when(() => mockAuthService.login(tEmail, tPassword)).thenAnswer((_) async => tToken);

      // Aguarda a inicialização do storage
      await container.read(sharedPreferencesProvider.future); 
      
      final authNotifier = container.read(authProvider.notifier);

      // Act
      await authNotifier.setLoading();
      await authNotifier.setToken(tToken); 

      // Assert
      final storedPrefs = await SharedPreferences.getInstance();
      expect(storedPrefs.getString('auth_token'), tToken);
      expect(container.read(authProvider).isAuthenticated, true);
    });

    test('should remove token from storage on logout', () async {
      // Arrange
      // Simula o estado inicial logado e persistido (necessário para o AuthNotifier)
      SharedPreferences.setMockInitialValues({'auth_token': tToken});
      await container.read(sharedPreferencesProvider.future);
      
      final authNotifier = container.read(authProvider.notifier);
      // O AuthNotifier já carregou o token no seu construtor
      expect(authNotifier.state.isAuthenticated, true); 

      // Act
      // Chama o logout, que deve limpar o estado e o storage
      await authNotifier.logout();

      // Assert
      final storedPrefs = await SharedPreferences.getInstance();
      expect(storedPrefs.getString('auth_token'), null);
      expect(container.read(authProvider).isAuthenticated, false);
    });
  });
}