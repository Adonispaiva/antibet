import 'package:antibet_mobile/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:antibet_mobile/infra/services/storage_service.dart';

/// Camada de Serviço de Infraestrutura para Autenticação.
///
/// Responsável pela lógica de negócios e comunicação com a API (Backend)
/// referente ao login, registro e gerenciamento de sessão do usuário.
class AuthService {
  final StorageService _storageService;

  // Simulação de dependência de um cliente HTTP (ex: Dio, Http)
  // final ApiClient _apiClient;

  // Injeção de dependência do StorageService
  AuthService(this._storageService);

  /// Tenta autenticar o usuário com email e senha.
  /// Retorna o [UserModel] em caso de sucesso.
  /// Lança uma [Exception] em caso de falha.
  Future<UserModel> login(String email, String password) async {
    try {
      // 1. Simulação de chamada de rede (API call)
      debugPrint('[AuthService] Tentando login para: $email');
      await Future.delayed(const Duration(milliseconds: 700));

      // 2. Simulação de resposta da API (JSON + Token)
      // (Usuário de teste)
      if (email == "adonis@inovexa.com" && password == "1234") {
        final mockApiResponse = {
          'token': 'jwt_token_simulado_123456abcdef',
          'user': {
            'id': 'user_uuid_001',
            'email': 'adonis@inovexa.com',
            'name': 'Adonis Paiva',
            'createdAt': '2025-11-01T10:00:00Z'
          }
        };

        // 3. Salvar o token
        await _storageService.saveToken(mockApiResponse['token'] as String);

        // 4. Parsear e retornar o UserModel
        final user = UserModel.fromJson(mockApiResponse['user'] as Map<String, dynamic>);
        debugPrint('[AuthService] Login bem-sucedido para: ${user.name}');
        return user;
        
      } else {
        // Simulação de credenciais inválidas
        throw Exception('Credenciais inválidas');
      }

    } catch (e) {
      debugPrint('[AuthService] Erro no login: $e');
      throw Exception('Falha no login. Verifique seus dados.');
    }
  }

  /// Tenta registrar um novo usuário.
  /// Retorna o [UserModel] em caso de sucesso.
  /// Lança uma [Exception] em caso de falha.
  Future<UserModel> register(String name, String email, String password) async {
    try {
      // 1. Simulação de chamada de rede (API call - POST /register)
      debugPrint('[AuthService] Tentando registrar: $email');
      await Future.delayed(const Duration(milliseconds: 900));

      // 2. Simulação de validação da API
      if (email == "adonis@inovexa.com") {
        throw Exception('E-mail já cadastrado.');
      }

      // 3. Simulação de resposta da API (JSON + Token)
      final mockApiResponse = {
        'token': 'jwt_token_simulado_novo_usuario_789xyz',
        'user': {
          'id': 'user_uuid_${DateTime.now().millisecondsSinceEpoch}',
          'email': email,
          'name': name,
          'createdAt': DateTime.now().toIso8601String()
        }
      };

      // 4. Salvar o token
      await _storageService.saveToken(mockApiResponse['token'] as String);

      // 5. Parsear e retornar o UserModel
      final user = UserModel.fromJson(mockApiResponse['user'] as Map<String, dynamic>);
      debugPrint('[AuthService] Registro bem-sucedido para: ${user.name}');
      return user;

    } catch (e) {
      debugPrint('[AuthService] Erro no registro: $e');
      // Repassa a exceção (ex: 'E-mail já cadastrado.')
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Verifica se existe um token válido e retorna o usuário.
  /// Retorna [UserModel] se autenticado, [null] se não.
  Future<UserModel?> checkAuthStatus() async {
    try {
      final token = await _storageService.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('[AuthService] Nenhum token encontrado. Usuário não autenticado.');
        return null;
      }

      // 1. Simulação de validação de token (API call)
      debugPrint('[AuthService] Validando token...');
      await Future.delayed(const Duration(milliseconds: 300));
      
      // 2. Simulação de resposta da API (retorno do usuário)
      final mockApiResponse = {
        'id': 'user_uuid_001',
        'email': 'adonis@inovexa.com',
        'name': 'Adonis Paiva',
        'createdAt': '2025-11-01T10:00:00Z'
      };

      // 3. Parsear e retornar o UserModel
      final user = UserModel.fromJson(mockApiResponse);
      debugPrint('[AuthService] Sessão restaurada para: ${user.name}');
      return user;

    } catch (e) {
      debugPrint('[AuthService] Erro ao checar status: $e');
      await _storageService.deleteToken(); // Limpa token inválido
      return null;
    }
  }

  /// Realiza o logout do usuário.
  Future<void> logout() async {
    debugPrint('[AuthService] Realizando logout...');
    // Apenas precisa limpar o token local
    await _storageService.deleteToken();
    debugPrint('[AuthService] Logout concluído.');
  }
}