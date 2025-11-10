// test/services/storage_service_test.dart

import 'package:antibet_mobile/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// O FlutterSecureStorage não permite a criação de um Mock automaticamente
// devido ao seu construtor const. Criamos um Mock que simula o comportamento
// do SDK subjacente, para fins de teste.

// Gerar mock (em um projeto real, isto seria gerado via build_runner)
@GenerateMocks([FlutterSecureStorage])
import 'storage_service_test.mocks.dart'; 

void main() {
  // A classe StorageService usa o construtor const do FlutterSecureStorage
  // Para testar, precisamos simular o comportamento da biblioteca.
  late MockFlutterSecureStorage mockStorage;
  // A injeção é feita via factory (simples para este exemplo)
  late StorageService storageService; 

  // Constantes para o teste
  const String testToken = 'ABC.XYZ.123';
  const String tokenKey = 'AUTH_JWT_TOKEN'; // Conforme definido em StorageService

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    // Simulação de injeção de dependência: 
    // Como é um Singleton, esta é uma abordagem simplificada, em projetos grandes,
    // utilizaríamos um Service Locator como GetIt ou Riverpod.
    // Aqui, estamos apenas garantindo que o mock está pronto para uso.
    storageService = StorageService(); 
    // O mock precisa ser configurado para o teste.
  });

  group('StorageService Unit Tests', () {
    
    // Testa se o método saveToken chama corretamente o método write
    test('saveToken deve chamar _storage.write com o token correto', () async {
      // Arrange
      // Configura o mock para não fazer nada quando write for chamado (void)
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value'))).thenAnswer((_) async {});

      // Act
      await storageService.saveToken(testToken);

      // Assert
      // Verifica se o método write foi chamado exatamente uma vez com os argumentos corretos
      verify(mockStorage.write(key: tokenKey, value: testToken)).called(1);
    });

    // Testa se o método readToken retorna o valor do token
    test('readToken deve retornar o token salvo', () async {
      // Arrange
      // Configura o mock para retornar o token de teste quando read for chamado
      when(mockStorage.read(key: tokenKey)).thenAnswer((_) async => testToken);

      // Act
      final result = await storageService.readToken();

      // Assert
      // Verifica se o valor retornado é o token de teste
      expect(result, equals(testToken));
      // Verifica se o método read foi chamado
      verify(mockStorage.read(key: tokenKey)).called(1);
    });

    // Testa se o método deleteToken chama corretamente o método delete
    test('deleteToken deve chamar _storage.delete', () async {
      // Arrange
      // Configura o mock para não fazer nada quando delete for chamado (void)
      when(mockStorage.delete(key: tokenKey)).thenAnswer((_) async {});

      // Act
      await storageService.deleteToken();

      // Assert
      // Verifica se o método delete foi chamado exatamente uma vez
      verify(mockStorage.delete(key: tokenKey)).called(1);
    });
  });
}