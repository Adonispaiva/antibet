import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:antibet/core/local_storage/storage_service.dart';
import 'package:antibet/features/auth/presentation/providers/auth_provider.dart';

// Mocks
class MockStorageService extends Mock implements StorageService {}

void main() {
  late MockStorageService mockStorageService;
  late ProviderContainer container;

  // Constante para a chave do token
  const tokenKey = 'auth_token';
  const tToken = 'jwt_token_on_device';

  setUp(() {
    mockStorageService = MockStorageService();
    // Registra fallback para String
    registerFallbackValue('any_key');
    registerFallbackValue('any_value');

    // Cria um ProviderContainer que sobrescreve o storageServiceProvider com o mock
    container = ProviderContainer(
      overrides: [
        storageServiceProvider.overrideWithValue(mockStorageService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthNotifier Initialization and Persistence', () {
    test('should load stored token during initialization if present', () {
      // Arrange
      // Simula que o StorageService retorna um token na inicialização
      when(() => mockStorageService.getString(tokenKey)).thenReturn(tToken);

      // Act
      // O notifier é criado e chama _init()
      final authNotifier = AuthNotifier(mockStorageService);
      
      // Assert
      expect(authNotifier.state.token, tToken);
      expect(authNotifier.state.isAuthenticated, true);
      verify(() => mockStorageService.getString(tokenKey)).called(1);
    });

    test('should remain unauthenticated during initialization if token is null', () {
      // Arrange
      when(() => mockStorageService.getString(tokenKey)).thenReturn(null);

      // Act
      final authNotifier = AuthNotifier(mockStorageService);
      
      // Assert
      expect(authNotifier.state.token, null);
      expect(authNotifier.state.isAuthenticated, false);
    });

    test('setToken should save token to storage and update state', () async {
      // Arrange
      when(() => mockStorageService.setString(tokenKey, tToken)).thenAnswer((_) async => true);
      // Inicializa o notifier após o setup (estado deslogado)
      final authNotifier = AuthNotifier(mockStorageService); 

      // Act
      await authNotifier.setToken(tToken);

      // Assert
      expect(authNotifier.state.token, tToken);
      expect(authNotifier.state.isAuthenticated, true);
      verify(() => mockStorageService.setString(tokenKey, tToken)).called(1);
    });

    test('logout should remove token from storage and clear state', () async {
      // Arrange
      // Simula um estado inicial logado
      when(() => mockStorageService.getString(tokenKey)).thenReturn(tToken);
      when(() => mockStorageService.remove(tokenKey)).thenAnswer((_) async => true);
      final authNotifier = AuthNotifier(mockStorageService);
      
      // Act
      await authNotifier.logout();

      // Assert
      expect(authNotifier.state.token, null);
      expect(authNotifier.state.isAuthenticated, false);
      verify(() => mockStorageService.remove(tokenKey)).called(1);
    });
  });
}