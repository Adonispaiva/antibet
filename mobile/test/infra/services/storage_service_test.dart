import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Versão adotada

// Importação do componente a ser testado
import 'package:antibet_mobile/infra/services/storage_service.dart';

// Gera o mock para a dependência de infraestrutura (FlutterSecureStorage)
@GenerateMocks([FlutterSecureStorage])
import 'storage_service_test.mocks.dart'; 

void main() {
  late MockFlutterSecureStorage mockSecureStorage;
  late StorageService storageService;
  
  const String testKey = 'test_auth_token_key';
  const String testToken = 'mock_secure_token_12345';

  // Configuração executada antes de cada teste
  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    // Injeta o mock no StorageService.
    // Assumimos que a classe StorageService aceita a dependência no construtor
    // ou que usa o Factory padrão que pode ser substituído em testes (como aqui).
    storageService = StorageService.withMocks(mockSecureStorage); 
  });

  tearDown(() {
    reset(mockSecureStorage);
  });

  group('StorageService Security Tests', () {

    // --- Teste 1: Escrita de Token ---
    test('writeToken deve chamar write na dependência de armazenamento seguro', () async {
      // Configuração: Simula sucesso na operação
      when(mockSecureStorage.write(
        key: testKey, 
        value: testToken, 
        // Assume-se que o StorageService passa um map de opções Android/iOS padrão, se necessário
        // Se a implementação não passa options, os matchers devem ser ajustados
        aOptions: anyNamed('aOptions'), 
        iOptions: anyNamed('iOptions'),
      )).thenAnswer((_) async => {});

      await storageService.writeToken(testKey, testToken);

      // Verifica se o método de escrita foi chamado com a chave e o valor corretos
      verify(mockSecureStorage.write(
        key: testKey, 
        value: testToken,
        aOptions: anyNamed('aOptions'), 
        iOptions: anyNamed('iOptions'),
      )).called(1);
    });

    // --- Teste 2: Leitura de Token (Token Encontrado) ---
    test('readToken deve retornar o token lido da dependência de armazenamento seguro', () async {
      // Configuração: Simula que o token foi encontrado
      when(mockSecureStorage.read(
        key: testKey,
        aOptions: anyNamed('aOptions'), 
        iOptions: anyNamed('iOptions'),
      )).thenAnswer((_) async => testToken);

      final result = await storageService.readToken(testKey);

      // Verifica se o valor retornado é o token esperado
      expect(result, testToken);

      // Verifica se o método de leitura foi chamado com a chave correta
      verify(mockSecureStorage.read(
        key: testKey,
        aOptions: anyNamed('aOptions'), 
        iOptions: anyNamed('iOptions'),
      )).called(1);
    });

    // --- Teste 3: Leitura de Token (Token Não Encontrado) ---
    test('readToken deve retornar nulo se nenhum token for encontrado', () async {
      // Configuração: Simula que nenhum token foi encontrado
      when(mockSecureStorage.read(
        key: testKey,
        aOptions: anyNamed('aOptions'), 
        iOptions: anyNamed('iOptions'),
      )).thenAnswer((_) async => null);

      final result = await storageService.readToken(testKey);

      // Verifica se o valor retornado é nulo
      expect(result, isNull);
    });

    // --- Teste 4: Exclusão de Token ---
    test('deleteToken deve chamar delete na dependência de armazenamento seguro', () async {
      // Configuração: Simula sucesso na operação
      when(mockSecureStorage.delete(
        key: testKey,
        aOptions: anyNamed('aOptions'), 
        iOptions: anyNamed('iOptions'),
      )).thenAnswer((_) async => {});

      await storageService.deleteToken(testKey);

      // Verifica se o método de exclusão foi chamado com a chave correta
      verify(mockSecureStorage.delete(
        key: testKey,
        aOptions: anyNamed('aOptions'), 
        iOptions: anyNamed('iOptions'),
      )).called(1);
    });
  });
}