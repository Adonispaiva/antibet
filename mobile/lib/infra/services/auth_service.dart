import 'package:mobile/infra/services/storage_service.dart';

// Placeholder temporário para o modelo de Usuário
// Este modelo deve ser definido em 'mobile/lib/domain/models/user_model.dart' futuramente.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? token;

  UserModel({required this.id, required this.name, required this.email, this.token});

  // Método placeholder para simular a criação de um usuário a partir da resposta da API
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 'default_id',
      name: json['name'] ?? 'Nome Usuário',
      email: json['email'] ?? 'usuario@antibet.com',
      token: json['token'],
    );
  }
}

// O AuthService é responsável pela comunicação com a API de Autenticação
// e pela persistência do token de sessão.
class AuthService {
  // Chave de armazenamento do token (constante de segurança)
  static const String _authTokenKey = 'auth_token';
  
  // O StorageService é injetado, seguindo o padrão da Arquitetura Limpa.
  final StorageService _storageService;

  AuthService(this._storageService);

  // === Métodos de Persistência de Token ===

  // Salva o token de autenticação no armazenamento local seguro
  Future<void> saveToken(String token) async {
    await _storageService.save(key: _authTokenKey, value: token);
  }

  // Recupera o token de autenticação do armazenamento local
  Future<String?> getToken() async {
    return await _storageService.read(key: _authTokenKey);
  }

  // Remove o token de autenticação
  Future<void> deleteToken() async {
    await _storageService.delete(key: _authTokenKey);
  }

  // === Métodos de Comunicação com a API (Futuro) ===

  // Simulação da chamada de API para Login
  Future<UserModel?> login({
    required String email, 
    required String password,
  }) async {
    // -----------------------------------------------------------------
    // TODO: Implementar a chamada HTTP real para o Backend
    // -----------------------------------------------------------------

    // Simulação de Sucesso/Falha
    if (email == 'teste@inovexa.com' && password == 'inovexa123') {
      // Simulação de Token (Token de teste real deve ser retornado pelo Backend)
      const testToken = 'sk_test_token_antibet_abc123';
      await saveToken(testToken);
      
      // Retorna o modelo do usuário com o token
      return UserModel(
        id: 'user_123', 
        name: 'Adonis', 
        email: email, 
        token: testToken,
      );
    } else {
      // Simulação de credenciais inválidas
      return null;
    }
  }

  // Simulação da chamada de API para Cadastro
  Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // -----------------------------------------------------------------
    // TODO: Implementar a chamada HTTP real para o Backend
    // -----------------------------------------------------------------

    // Simulação de Sucesso/Falha
    if (email.contains('@') && password.length >= 6) {
      // Após o registro, normalmente o Backend retorna o token de sessão.
      const testToken = 'sk_test_token_antibet_def456';
      await saveToken(testToken);
      
      return UserModel(
        id: 'user_456', 
        name: name, 
        email: email, 
        token: testToken,
      );
    } else {
      // Simulação de falha de validação ou e-mail já em uso
      return null;
    }
  }

  // Simulação da chamada de API para Logout
  Future<void> logout() async {
    // -----------------------------------------------------------------
    // TODO: Implementar a chamada HTTP real para o Backend (Invalidar Token)
    // -----------------------------------------------------------------
    await deleteToken();
  }
}