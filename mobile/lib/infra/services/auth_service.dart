import 'package:antibet_mobile/core/domain/user_model.dart';
import 'package:antibet_mobile/infra/services/storage_service.dart';

/// Uma classe de exceção personalizada para falhas de autenticação.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

/// O serviço de autenticação é responsável pela comunicação com a API (simulada) e
/// pela orquestração com o StorageService para persistência segura do token.
class AuthService {
  final StorageService _storageService;

  // A chave para o token de autenticação, mantida no serviço de infraestrutura.
  static const String _authKey = 'authToken'; 

  AuthService(this._storageService);

  /// Simula uma chamada de login à API, persistindo o token em caso de sucesso.
  Future<UserModel> login(String email, String password) async {
    // --- SIMULAÇÃO DE LÓGICA DE API ---
    if (email == 'user@inovexa.com.br' && password == 'inovexa123') {
      // Token fictício simulando resposta da API
      const token = 'xyz789_mock_jwt_token_for_inovexa_user'; 
      await _storageService.writeToken(_authKey, token);
      
      // Retorna o modelo do usuário (idealmente, deserializado da resposta da API)
      return const UserModel(id: '123', email: email);
    } else {
      throw AuthException('Credenciais inválidas. Por favor, tente novamente.');
    }
  }

  /// Simula uma chamada de registro à API.
  /// No mundo real, registraria o usuário e possivelmente retornaria um token.
  Future<UserModel> register(String email, String password) async {
    // --- SIMULAÇÃO DE LÓGICA DE API ---
    if (email.contains('fail')) { // Regra de falha simulada
      throw AuthException('Email já está em uso ou inválido.');
    }
    
    // Simula sucesso de registro.
    // Em muitos sistemas, o registro bem-sucedido resulta em login automático.
    const token = 'abc456_mock_jwt_token_for_new_user';
    await _storageService.writeToken(_authKey, token);

    // Retorna o modelo do novo usuário
    return UserModel(id: UniqueKey().toString(), email: email);
  }

  /// Verifica se um token de autenticação está armazenado de forma segura.
  Future<bool> isTokenStored() async {
    final token = await _storageService.readToken(_authKey);
    return token != null;
  }

  /// Remove o token do armazenamento seguro, realizando o logout.
  Future<void> logout() async {
    await _storageService.deleteToken(_authKey);
  }
}