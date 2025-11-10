import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:antibet/src/core/services/auth_service.dart';

// Mock do StorageService (definido no auth_service.dart para fins de teste)
class MockStorageService extends Mock implements StorageService {
  @override
  Future<void> saveToken(String token) => super.noSuchMethod(
        Invocation.method(#saveToken, [token]),
        returnValue: Future.value(null),
      ) as Future<void>;

  @override
  Future<String?> loadToken() => super.noSuchMethod(
        Invocation.method(#loadToken, []),
        returnValue: Future.value(null),
      ) as Future<String?>;
  
  @override
  Future<void> deleteToken() => super.noSuchMethod(
        Invocation.method(#deleteToken, []),
        returnValue: Future.value(null),
      ) as Future<void>;
}

void main() {
  late MockStorageService mockStorageService;
  late AuthService authService;

  setUp(() {
    mockStorageService = MockStorageService();
    // Injeta o mock no serviço
    authService = AuthService(mockStorageService);
  });

  group('AuthService - Login Logic', () {
    test('login should return true, save token, and set authToken on success', () async {
      const email = 'test@inovexa.com';
      const password = 'secure_password';

      final success = await authService.login(email, password);

      // 1. Deve retornar sucesso
      expect(success, isTrue);

      // 2. O token deve ser gerado e armazenado no serviço
      expect(authService.authToken, isNotNull);
      expect(authService.authToken!.startsWith('jwt_'), isTrue);
      
      // 3. O método saveToken do StorageService deve ser chamado com o token gerado
      verify(mockStorageService.saveToken(authService.authToken!)).called(1);
    });

    test('login should return false if password is "fail" (simulated backend error)', () async {
      const email = 'test@inovexa.com';
      const password = 'fail';

      final success = await authService.login(email, password);

      // 1. Deve retornar falha
      expect(success, isFalse);

      // 2. O token NÃO deve ter sido salvo ou alterado
      expect(authService.authToken, isNull);
      verifyNever(mockStorageService.saveToken(any));
    });
  });
  
  group('AuthService - Logout Logic', () {
    test('logout should delete token and clear internal state', () async {
      // Setup: Simula que o usuário está logado
      await authService.login('user@inovexa.com', 'pass');
      expect(authService.authToken, isNotNull);

      await authService.logout();

      // 1. O estado interno deve ser limpo
      expect(authService.authToken, isNull);

      // 2. O método deleteToken do StorageService deve ser chamado
      verify(mockStorageService.deleteToken()).called(1);
    });
  });

  group('AuthService - Check Status', () {
    test('checkAuthenticationStatus should return true if a valid token is loaded', () async {
      const validToken = 'mock_valid_token_789';
      
      // Setup: Mocka o loadToken para retornar um token válido
      when(mockStorageService.loadToken()).thenAnswer((_) => Future.value(validToken));

      final isAuthenticated = await authService.checkAuthenticationStatus();

      // 1. Deve retornar autenticado
      expect(isAuthenticated, isTrue);
      
      // 2. O token interno do serviço deve ser setado
      expect(authService.authToken, equals(validToken));
      
      // 3. O método loadToken do StorageService deve ser chamado
      verify(mockStorageService.loadToken()).called(1);
    });

    test('checkAuthenticationStatus should return false if no token is found', () async {
      // Setup: Mocka o loadToken para retornar null
      when(mockStorageService.loadToken()).thenAnswer((_) => Future.value(null));

      final isAuthenticated = await authService.checkAuthenticationStatus();

      // 1. Deve retornar não autenticado
      expect(isAuthenticated, isFalse);
      
      // 2. O token interno deve ser null
      expect(authService.authToken, isNull);
    });
  });
}