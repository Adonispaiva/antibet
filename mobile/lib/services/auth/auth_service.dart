import 'package:flutter/foundation.dart';
import 'package:antibet/notifiers/auth/auth_notifier.dart'; // Importa o modelo de usuário

/// Exceção personalizada para falhas de login.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

/// Serviço de Autenticação (AuthService)
///
/// Responsável pela lógica de comunicação com a API (simulada aqui) e
/// persistência/verificação de tokens (segurança).
/// Ele é utilizado pelo AuthNotifier para alterar o estado.
class AuthService {
  // Simulação de um repositório para persistir o token de forma segura
  // Na vida real, usaria flutter_secure_storage ou similar.
  String? _authToken; 

  // Simulação de um cliente HTTP
  // Na vida real, usaria Dio, http, ou outro cliente para a API.
  Future<Map<String, dynamic>> _httpPost(String endpoint, Map<String, dynamic> data) async {
    // Simula a latência da rede
    await Future.delayed(const Duration(seconds: 1)); 

    if (endpoint == '/api/login') {
      if (data['email'] == 'adonis@inovexa.com' && data['password'] == 'senha123') {
        // Simulação de resposta de sucesso com token
        return {
          'token': 'mock_secure_token_12345',
          'user': {
            'id': '123',
            'email': data['email'],
          }
        };
      } else {
        // Simulação de erro de credenciais inválidas
        throw AuthException('Credenciais inválidas. Verifique seu email e senha.');
      }
    }
    throw AuthException('Endpoint desconhecido.');
  }


  /// Simula o processo de login: Chama a API e salva o token.
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _httpPost('/api/login', {
        'email': email,
        'password': password,
      });

      // 1. Persistir o token de forma segura
      _authToken = response['token'];
      if (kDebugMode) {
        print('Token recebido e salvo: $_authToken');
      }

      // 2. Criar e retornar o modelo de usuário
      final userData = response['user'];
      return UserModel(
        id: userData['id'],
        email: userData['email'],
      );
    } on AuthException {
      rethrow; // Propaga a exceção específica de autenticação
    } catch (e) {
      // Tratar outros erros de rede/parsing
      throw AuthException('Falha na comunicação com o servidor. Tente novamente.');
    }
  }

  /// Simula a verificação de um token existente para login automático.
  Future<UserModel?> checkToken() async {
    // 1. Tenta recuperar o token persistido
    // Na vida real: _authToken = await SecureStorage.read(key: 'auth_token');
    
    // Simulação: Apenas verifica se o mock token está setado
    if (_authToken != null) {
      // 2. Simula a chamada para validar o token no backend (ex: /api/validate-token)
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Simulação: Token é válido, retorna um UserModel
      return const UserModel(id: '123', email: 'adonis@inovexa.com');
    }
    
    return null;
  }

  /// Simula o processo de logout: Limpa o token.
  Future<void> logout() async {
    // 1. Limpa o token do armazenamento seguro
    // Na vida real: await SecureStorage.delete(key: 'auth_token');
    _authToken = null;
    
    // 2. Opcional: Notifica o backend sobre o logout (ex: invalidar token)
    await Future.delayed(const Duration(milliseconds: 100)); 
    
    if (kDebugMode) {
      print('Sessão de usuário encerrada. Token limpo.');
    }
  }
}