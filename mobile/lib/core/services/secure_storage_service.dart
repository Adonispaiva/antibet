import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 1. DEFINIÇÃO DA INTERFACE (ISecureStorageService)
/// Define o contrato para um serviço de armazenamento seguro.
/// Isso permite que a lógica de negócios (como o UserProvider)
/// dependa desta abstração, facilitando a substituição
/// por mocks em testes.
abstract class ISecureStorageService {
  /// Escreve um par chave-valor no armazenamento seguro.
  Future<void> write({required String key, required String value});

  /// Lê o valor associado a uma chave.
  /// Retorna 'null' se a chave não for encontrada.
  Future<String?> read({required String key});

  /// Deleta o valor associado a uma chave.
  Future<void> delete({required String key});

  /// Deleta todos os dados do armazenamento seguro.
  Future<void> deleteAll();
}

// 2. IMPLEMENTAÇÃO REAL (SecureStorageService)
/// Implementação concreta da interface usando o pacote [flutter_secure_storage].
class SecureStorageService implements ISecureStorageService {
  const SecureStorageService({required this.storage});
  
  final FlutterSecureStorage storage;

  @override
  Future<void> write({required String key, required String value}) async {
    try {
      await storage.write(key: key, value: value);
    } catch (e) {
      // TODO: Tratar ou registrar o erro de escrita
      // Em um app de produção, poderíamos lançar um CacheFailure
      print('Erro ao escrever no SecureStorage: $e');
    }
  }

  @override
  Future<String?> read({required String key}) async {
    try {
      return await storage.read(key: key);
    } catch (e) {
      print('Erro ao ler do SecureStorage: $e');
      return null;
    }
  }

  @override
  Future<void> delete({required String key}) async {
    try {
      await storage.delete(key: key);
    } catch (e) {
      print('Erro ao deletar do SecureStorage: $e');
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await storage.deleteAll();
    } catch (e) {
      print('Erro ao deletar tudo do SecureStorage: $e');
    }
  }
}

// 3. DEFINIÇÃO DO PROVIDER (secureStorageServiceProvider)

/// Provider global para a instância do [FlutterSecureStorage].
/// Isso é feito para que a instância seja única.
final _secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    // Configurações de Acessibilidade (ex: para iOS)
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );
});

/// Provider que expõe a implementação *real* (SecureStorageService)
/// da interface (ISecureStorageService).
///
/// A UI e outros providers devem usar este 'secureStorageServiceProvider'
/// e depender da interface, não da implementação concreta.
final secureStorageServiceProvider = Provider<ISecureStorageService>((ref) {
  final storage = ref.watch(_secureStorageProvider);
  return SecureStorageService(storage: storage);
});