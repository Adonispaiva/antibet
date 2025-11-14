// mobile/lib/core/services/auth_service.dart

import 'dart:convert';
import 'package:antibet/core/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:antibet/config/app_config.dart'; // Importação do AppConfig

// const String _kApiUrl = 'http://localhost:3000/api/auth'; // Removido!

const String _tokenKey = 'auth_token';

class AuthService {
  final StorageService _storageService;
  
  AuthService(this._storageService);

  Future<String?> getToken() async => await _storageService.read(_tokenKey);
  
  Future<void> saveToken(String token) async => await _storageService.write(_tokenKey, token);
  
  Future<void> clearToken() async => await _storageService.delete(_tokenKey);

  /// Tenta realizar o login com a API do Backend.
  Future<bool> attemptLogin(String email, String password) async {
    final url = Uri.parse('${AppConfig.apiUrl}/auth/login'); // Usando AppConfig
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        
        if (token != null) {
          await saveToken(token);
          debugPrint('AuthService: Login bem-sucedido. Token salvo.');
          return true;
        }
      }
      
      debugPrint('AuthService: Falha no login. Status: ${response.statusCode}');
      return false;
      
    } catch (e) {
      debugPrint('AuthService: Erro de conexão durante o login: $e');
      return false;
    }
  }
  
  /// Tenta realizar o registro de um novo usuário com a API do Backend.
  Future<bool> attemptRegistration(String name, String email, String password) async {
    final url = Uri.parse('${AppConfig.apiUrl}/auth/register'); // Usando AppConfig
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token']; 
        
        if (token != null) {
          await saveToken(token);
          debugPrint('AuthService: Registro bem-sucedido. Token salvo.');
          return true;
        }
      }
      
      debugPrint('AuthService: Falha no registro. Status: ${response.statusCode}');
      // Em caso de falha de validação (status 400), o corpo da resposta pode conter detalhes.
      if (response.statusCode == 400) {
           debugPrint('AuthService: Detalhes do erro: ${response.body}');
      }
      return false;
      
    } catch (e) {
      debugPrint('AuthService: Erro de conexão durante o registro: $e');
      return false;
    }
  }
}