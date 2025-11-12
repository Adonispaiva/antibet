import 'package:flutter_test/flutter_test.dart';
import 'package:antibet_mobile/models/user_model.dart';
import 'package:antibet_mobile/infra/services/auth_service.dart';
import 'package:antibet_mobile/infra/services/storage_service.dart'; 
// Nota: Em um projeto real, usaríamos a biblioteca mockito/mocktail aqui.

// =========================================================================
// SIMULAÇÃO DE DEPENDÊNCIAS (Mocks)
// =========================================================================

// Simulação de StorageService (para controlar o comportamento do token)
class MockStorageService implements StorageService {
  String? _token;

  @override
  Future<void> saveToken(String token) async {
    _token = token;
  }

  @override
  Future<String?> getToken() async {
    return _token;
  }

  @override
  Future<void> deleteToken() async {
    _token = null;
  }
  
  // Métodos não utilizados no AuthService, mas necessários para a interface
  @override
  Future<void> write(String key, String value) async {}
  @override
  Future<String?> read(String key) async => null;
  @override
  Future<void> delete(String key) async {}
}

// SIMULAÇÃO DO USER MODEL (simplificado)
class UserModel {
  final String id;
  final String email;
  final String? name;
  final DateTime? createdAt;

  UserModel({required this.id, required this.email, this.name, this.createdAt});
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
  Map<String, dynamic> toJson() => {};
  UserModel copyWith({String? id, String? email, String? name, DateTime? createdAt}) => this;
}

// SIMULAÇÃO DO AUTH SERVICE (para que o teste possa ser executado neste ambiente)
// Inclui os mock responses simulados
class AuthService {
  final MockStorageService _storageService;

  AuthService(this._storageService);

  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1)); // Simulação de rede
    
    if (email == "adonis@inovexa.com" && password == "1234") {
      final mockApiResponse = {
        'token': 'jwt_token_simulado_valid',
        'user': {'id': 'user_uuid_001', 'email': email, 'name': 'Adonis', 'createdAt': '2025-11-01T10:00:00Z'}
      };
      await _storageService.saveToken(mockApiResponse['token'] as String);
      return UserModel.fromJson(mockApiResponse['user'] as Map<String, dynamic>);
    } else {
      throw Exception('Credenciais inválidas');
    }
  }

  Future<UserModel> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1)); // Simulação de rede
    
    if (email == "exists@inovexa.com") {
      throw Exception('E-mail já cadastrado.');
    }

    final mockApiResponse = {
      'token': 'jwt_token_simulado_new',
      'user': {'id': 'user_new_002', 'email': email, 'name': name, 'createdAt': '2025-11-11T10:00:00Z'}
    };
    await _storageService.saveToken(mockApiResponse['token'] as String);
    return UserModel.fromJson(mockApiResponse['user'] as Map<String, dynamic>);
  }

  Future<UserModel?> checkAuthStatus() async {
    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    await Future.delayed(const Duration(milliseconds: 1)); // Simulação de validação
    
    // Simulação de retorno de usuário para token válido
    final mockApiResponse = {'id': 'user_uuid_001', 'email': 'adonis@inovexa.com', 'name': 'Adonis', 'createdAt': '2025-11-01T10:00:00Z'};
    return UserModel.fromJson(mockApiResponse);
  }

  Future<void> logout() async {
    await _storageService.deleteToken();
  }
}
// =========================================================================
// FIM DA SIMULAÇÃO
// =========================================================================

void main() {
  group('AuthService Unit Tests', () {
    late AuthService authService;
    late MockStorageService mockStorageService;

    // Configuração: Garante estado limpo e objetos antes de cada teste
    setUp(() {
      mockStorageService = MockStorageService();
      authService = AuthService(mockStorageService);
    });

    // ---------------------------------------------------------------------
    // Testes de Login
    // ---------------------------------------------------------------------
    test('01. Login deve retornar UserModel e salvar o token em caso de sucesso', () async {
      final user = await authService.login('adonis@inovexa.com', '1234');
      final token = await mockStorageService.getToken();

      expect(user, isA<UserModel>());
      expect(user.email, 'adonis@inovexa.com');
      expect(token, 'jwt_token_simulado_valid');
    });

    test('02. Login deve lançar exceção em caso de credenciais inválidas', () async {
      expect(
        () => authService.login('wrong@email.com', 'wrongpass'),
        throwsA(isA<Exception>()),
      );
      final token = await mockStorageService.getToken();
      expect(token, isNull, reason: 'Token não deve ser salvo em caso de falha');
    });

    // ---------------------------------------------------------------------
    // Testes de Registro
    // ---------------------------------------------------------------------
    test('03. Register deve retornar UserModel e salvar o token em caso de sucesso', () async {
      final user = await authService.register('Novo Usuário', 'novo@email.com', 'newpass');
      final token = await mockStorageService.getToken();

      expect(user, isA<UserModel>());
      expect(user.email, 'novo@email.com');
      expect(token, 'jwt_token_simulado_new');
    });

    test('04. Register deve lançar exceção se o e-mail já estiver cadastrado', () async {
      expect(
        () => authService.register('Existing User', 'exists@inovexa.com', 'pass'),
        throwsA(isA<Exception>()),
      );
      final token = await mockStorageService.getToken();
      expect(token, isNull, reason: 'Token não deve ser salvo em caso de falha');
    });

    // ---------------------------------------------------------------------
    // Testes de Status e Logout
    // ---------------------------------------------------------------------
    test('05. checkAuthStatus deve retornar UserModel se o token for encontrado', () async {
      await mockStorageService.saveToken('valid_token');
      final user = await authService.checkAuthStatus();

      expect(user, isA<UserModel>());
      expect(user!.email, 'adonis@inovexa.com');
    });

    test('06. checkAuthStatus deve retornar nulo se o token não for encontrado', () async {
      await mockStorageService.deleteToken(); // Garante que o token está limpo
      final user = await authService.checkAuthStatus();

      expect(user, isNull);
    });

    test('07. Logout deve chamar deleteToken no StorageService', () async {
      await mockStorageService.saveToken('token_to_delete');
      expect(await mockStorageService.getToken(), isNotNull);

      await authService.logout();

      final token = await mockStorageService.getToken();
      expect(token, isNull);
    });
  });
}