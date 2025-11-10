import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Importações dos componentes a serem testados e dependências
import 'package:antibet_mobile/infra/services/auth_service.dart';
import 'package:antibet_mobile/infra/services/storage_service.dart';

// Gera o mock para o StorageService
@GenerateMocks([StorageService])
import 'auth_service_test.mocks.dart'; 

void main() {
  late MockStorageService mockStorageService;
  late AuthService authService;
  const String authKey = 'authToken'; // Chave privada definida no AuthService

  // Configuração executada antes de cada teste
  setUp(() {
    mockStorageService = MockStorageService();
    // Injeta o mock no AuthService
    authService = AuthService(mockStorageService); 
  });

  // Limpeza executada após cada teste
  tearDown(() {
    reset(mockStorageService);
  });

  group('AuthService - Login Tests', () {
    test('login deve retornar UserModel e escrever o token no StorageService para credenciais válidas', () async {
      // Configuração: Simula sucesso na persistência do token
      when(mockStorageService.writeToken(any, any)).thenAnswer((_) async {});

      final user = await authService.login('user@inovexa.com.br', 'inovexa123');

      // Verifica se o modelo de usuário foi retornado corretamente
      expect(user, isNotNull);
      expect(user.email, 'user@inovexa.com.br');

      // Verifica se o writeToken foi chamado com a chave correta e um token não-nulo
      verify(mockStorageService.writeToken(authKey, any)).called(1);
    });

    test('login deve lançar AuthException para credenciais inválidas', () async {
      // O AuthService tem a lógica de simulação de falha interna
      // Não deve haver interação com o StorageService neste caso
      
      expect(
        () => authService.login('wrong@test.com', 'wrongpass'), 
        throwsA(isA<AuthException>()),
      );

      // Verifica que o writeToken nunca foi chamado
      verifyNever(mockStorageService.writeToken(any, any));
    });
  });

  group('AuthService - Register Tests', () {
    test('register deve retornar UserModel e escrever o token no StorageService', () async {
      // Configuração: Simula sucesso na persistência do token
      when(mockStorageService.writeToken(any, any)).thenAnswer((_) async {});

      final user = await authService.register('newuser@app.com', 'securepass');

      // Verifica se o modelo de usuário foi retornado corretamente
      expect(user, isNotNull);
      expect(user.email, 'newuser@app.com');

      // Verifica se o writeToken foi chamado após o registro
      verify(mockStorageService.writeToken(authKey, any)).called(1);
    });

    test('register deve lançar AuthException em caso de falha simulada', () async {
      // O AuthService tem a lógica de simulação de falha para emails com 'fail'
      
      expect(
        () => authService.register('fail@app.com', 'securepass'), 
        throwsA(isA<AuthException>()),
      );

      // Verifica que o writeToken nunca foi chamado
      verifyNever(mockStorageService.writeToken(any, any));
    });
  });

  group('AuthService - Token Management Tests', () {
    test('isTokenStored deve retornar true se readToken retornar um valor não-nulo', () async {
      // Configuração: Simula que o token existe
      when(mockStorageService.readToken(authKey)).thenAnswer((_) async => 'mock_token');

      final result = await authService.isTokenStored();

      expect(result, isTrue);
      verify(mockStorageService.readToken(authKey)).called(1);
    });

    test('isTokenStored deve retornar false se readToken retornar nulo', () async {
      // Configuração: Simula que o token não existe
      when(mockStorageService.readToken(authKey)).thenAnswer((_) async => null);

      final result = await authService.isTokenStored();

      expect(result, isFalse);
      verify(mockStorageService.readToken(authKey)).called(1);
    });

    test('logout deve chamar deleteToken no StorageService', () async {
      // Configuração: Simula sucesso na remoção do token
      when(mockStorageService.deleteToken(authKey)).thenAnswer((_) async {});

      await authService.logout();

      // Verifica se o deleteToken foi chamado
      verify(mockStorageService.deleteToken(authKey)).called(1);
    });
  });
}