// Simulação de um serviço de armazenamento seguro (ex: Flutter Secure Storage, SharedPreferences)
// Nota: O StorageService real é injetado, mas a simulação básica está aqui.
class StorageService {
  Future<void> saveToken(String token) async {
    // Implementação real: armazenar token em local seguro
    print('Token salvo: $token');
  }

  Future<String?> loadToken() async {
    // Implementação real: carregar token
    return Future.value('mock_valid_token_123'); // Simulação de token válido
  }

  Future<void> deleteToken() async {
    // Implementação real: deletar token
    print('Token deletado.');
  }
}

class AuthService {
  final StorageService _storageService;
  // Chave de autenticação (simulada)
  String? _authToken;

  AuthService(this._storageService);

  // Getter para o token
  String? get authToken => _authToken;

  /// Simula a chamada de login ao backend.
  Future<bool> login(String email, String password) async {
    // Mock: Simula falha se a senha for "fail"
    if (password == 'fail') {
      return false; 
    }
    
    // Simulação de chamada ao backend (FastAPI)
    await Future.delayed(const Duration(milliseconds: 500)); 

    // Simulação de sucesso: Geração e salvamento do token
    final token = 'jwt_${DateTime.now().millisecondsSinceEpoch}';
    _authToken = token;
    await _storageService.saveToken(token);
    
    return true;
  }

  /// Limpa o estado de autenticação.
  Future<void> logout() async {
    _authToken = null;
    await _storageService.deleteToken();
  }

  /// Verifica se há um token válido e carrega o estado de login na inicialização.
  Future<bool> checkAuthenticationStatus() async {
    final storedToken = await _storageService.loadToken();

    if (storedToken != null && _validateToken(storedToken)) {
      _authToken = storedToken;
      return true;
    }
    return false;
  }

  // Simula a validação de token (expiração, formato, etc.)
  bool _validateToken(String token) {
    // Lógica real envolveria verificar a validade no backend ou decodificar JWT.
    // Para o mock, qualquer token carregado é considerado válido.
    return token.startsWith('mock_valid_token') || token.startsWith('jwt_');
  }
}