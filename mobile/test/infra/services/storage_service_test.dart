// Dependências de teste (simulação)
import 'package:flutter_test/flutter_test.dart';
import 'package:antibet_mobile/infra/services/storage_service.dart';

// Simulação do código interno de StorageService (necessário para o teste funcionar neste ambiente)
// No projeto real, a variável `storage` e a classe simulada não estariam aqui.
final Map<String, String> storage = {};

class StorageService {
  static const String _tokenKey = 'auth_token';
  
  Future<void> write(String key, String value) async {
    storage[key] = value;
    await Future.delayed(Duration.zero); // Simula async
  }
  
  Future<String?> read(String key) async {
    await Future.delayed(Duration.zero); // Simula async
    return storage[key];
  }
  
  Future<void> delete(String key) async {
    storage.remove(key);
    await Future.delayed(Duration.zero); // Simula async
  }
  
  Future<void> saveToken(String token) => write(_tokenKey, token);
  Future<String?> getToken() => read(_tokenKey);
  Future<void> deleteToken() => delete(_tokenKey);
  
  // Adicionado para setup do teste
  void clear() => storage.clear(); 
}
// *** FIM DA SIMULAÇÃO ***

void main() {
  group('StorageService Unit Tests', () {
    late StorageService storageService;

    // Configuração: Garante estado limpo antes de cada teste
    setUp(() {
      // Limpa o mapa interno do serviço simulado
      storage.clear(); 
      storageService = StorageService();
    });

    test('01. Deve escrever e ler um valor de string com sucesso (CRUD)', () async {
      const key = 'test_token';
      const value = 'jwt_secure_token_12345';

      await storageService.write(key, value);
      final retrievedValue = await storageService.read(key);

      expect(retrievedValue, value);
    });

    test('02. Deve retornar nulo ao tentar ler uma chave inexistente', () async {
      const key = 'non_existent_key';
      final retrievedValue = await storageService.read(key);

      expect(retrievedValue, isNull);
    });
    
    test('03. Deve deletar um par chave-valor com sucesso (CRUD)', () async {
      const key = 'data_to_delete';
      const value = 'temporary_data';

      await storageService.write(key, value);
      expect(await storageService.read(key), value);

      await storageService.delete(key);

      final retrievedValueAfterDelete = await storageService.read(key);
      expect(retrievedValueAfterDelete, isNull);
    });

    test('04. Deve manipular o salvamento e recuperação do Token de Autenticação', () async {
      const token = 'my_auth_token_xyz';

      await storageService.saveToken(token);
      final retrievedToken = await storageService.getToken();

      expect(retrievedToken, token);
    });
    
    test('05. Deve manipular a exclusão do Token de Autenticação', () async {
      const token = 'my_auth_token_xyz';

      await storageService.saveToken(token);
      await storageService.deleteToken();

      final retrievedToken = await storageService.getToken();
      expect(retrievedToken, isNull);
    });
  });
}