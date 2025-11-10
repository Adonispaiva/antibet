import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Serviço singleton para gerenciar o armazenamento seguro de dados.
///
/// Encapsula o 'flutter_secure_storage' para abstrair a implementação
/// e facilitar a manutenção e testes.
class StorageService {
  // Instância singleton
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final _storage = const FlutterSecureStorage(
    // Configurações de segurança (opcional, mas recomendado)
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Chave padronizada para o token JWT
  static const String _jwtTokenKey = 'AUTH_JWT_TOKEN';

  /// Salva o token JWT no armazenamento seguro.
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _jwtTokenKey, value: token);
    } catch (e) {
      // Tratar erro de escrita (ex: dispositivo sem Keystore)
      print('Erro ao salvar token no SecureStorage: $e');
    }
  }

  /// Lê o token JWT do armazenamento seguro.
  Future<String?> readToken() async {
    try {
      return await _storage.read(key: _jwtTokenKey);
    } catch (e) {
      print('Erro ao ler token no SecureStorage: $e');
      return null;
    }
  }

  /// Deleta o token JWT do armazenamento seguro.
  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _jwtTokenKey);
    } catch (e) {
      print('Erro ao deletar token no SecureStorage: $e');
    }
  }
}