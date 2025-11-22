import 'package:flutter/foundation.dart';

/// Notifier responsável por gerenciar o estado de autenticação do usuário.
/// É o pilar da Camada de Estado (Notifiers), responsável por notificar 
/// os *widgets* de qualquer mudança no status de login.
class AuthNotifier extends ChangeNotifier {
  // Estado que reflete se o usuário está logado ou não.
  bool _isLoggedIn = false;
  
  // Getter público para acessar o estado de login de forma imutável.
  bool get isLoggedIn => _isLoggedIn;

  // Variável para armazenar o token ou informação do usuário, simulando
  // uma sessão ativa. Por enquanto, apenas um placeholder.
  String? _userToken;
  String? get userToken => _userToken;

  /// Método de simulação de login.
  /// No futuro, esta função irá se conectar ao AuthService.
  Future<void> login(String email, String password) async {
    // Simulação de delay de API
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Simulação de sucesso no login
    _isLoggedIn = true;
    _userToken = 'simulated_jwt_token_for_$email';
    
    // Notifica todos os widgets que estão escutando o AuthNotifier sobre a mudança de estado.
    notifyListeners();
  }

  /// Método de simulação de logout.
  /// No futuro, esta função irá limpar a sessão do AuthService e StorageService.
  Future<void> logout() async {
    // Simulação de delay para limpar sessão
    await Future.delayed(const Duration(milliseconds: 500));
    
    _isLoggedIn = false;
    _userToken = null;
    
    // Notifica todos os widgets para atualizar a UI (Ex: ir para LoginScreen).
    notifyListeners();
  }
}