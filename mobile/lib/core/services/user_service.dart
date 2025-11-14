// mobile/lib/core/services/user_service.dart

import 'dart:convert';
import 'package:antibet/core/services/storage_service.dart';
import 'package:antibet/core/services/auth_service.dart';
import 'package:antibet/features/user/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:antibet/config/app_config.dart'; // Importação do AppConfig

// const String _kApiUrl = 'http://localhost:3000/api/user'; // Removido!

class UserService {
  final StorageService _storageService; 
  final AuthService _authService;

  UserService(this._storageService, this._authService);

  /// Busca o perfil do usuário logado (usado pelo AuthNotifier).
  Future<UserModel?> fetchUserProfile() async {
    final token = await _authService.getToken();

    if (token == null) {
      debugPrint('UserService: Sem token. Falha ao buscar perfil.');
      return null;
    }

    // Usando AppConfig para a URL base
    final url = Uri.parse('${AppConfig.apiUrl}/user/profile'); 

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Injeção do token JWT
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('UserService: Perfil buscado com sucesso.');
        return UserModel.fromJson(data);
      }
      
      debugPrint('UserService: Falha ao buscar perfil. Status: ${response.statusCode}');
      return null;
      
    } catch (e) {
      debugPrint('UserService: Erro de conexão ao buscar perfil: $e');
      return null;
    }
  }
  
  /// Atualiza o perfil do usuário.
  Future<UserModel> updateProfile(UserModel user) async {
    final token = await _authService.getToken();
    
    if (token == null) {
        throw Exception('Não autenticado. Não é possível atualizar o perfil.');
    }

    // Usando AppConfig para a URL base
    final url = Uri.parse('${AppConfig.apiUrl}/user/${user.id}'); // Endpoint PATCH /api/user/:id

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(user.toJson()), // Envia o modelo atualizado
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('UserService: Perfil atualizado com sucesso.');
        return UserModel.fromJson(data);
      }
      
      debugPrint('UserService: Falha ao atualizar perfil. Status: ${response.statusCode}');
      throw Exception('Falha na atualização do perfil.');

    } catch (e) {
      debugPrint('UserService: Erro de conexão ao atualizar perfil: $e');
      throw Exception('Erro de conexão ou servidor ao atualizar perfil.');
    }
  }
}