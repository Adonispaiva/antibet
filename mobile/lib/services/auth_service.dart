// lib/services/auth_service.dart

import 'dart:async';
// Assumindo que você terá um pacote de http instalado (ex: 'package:http/http.dart' as http;)
// Por enquanto, a requisição é simulada.
// import 'package:http/http.dart' as http; 
import 'package:antibet_mobile/core/app_constants.dart';
import 'package:antibet_mobile/core/models/user_model.dart';

class AuthService {
  // Padrão Singleton: Instância única do serviço
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Variável de estado para armazenar o usuário autenticado
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  
  // Getter para verificar o estado de autenticação
  bool get isAuthenticated => _currentUser != null;

  // Stream Controller para gerenciar mudanças de estado de autenticação
  final StreamController<UserModel?> _userController = StreamController.broadcast();
  Stream<UserModel?> get userChanges => _userController.stream;

  /// Simula a chamada de login para a API.
  Future<UserModel> login(String email, String password) async {
    // 1. Construir a URL da API (usando AppConstants)
    final url = '${AppConstants.baseUrl}/auth/login';

    // 2. Simulação da Requisição HTTP (Substituir com a lógica real de HTTP)
    try {
      // final response = await http.post(Uri.parse(url), body: {
      //   'email': email,
      //   'password': password,
      // });
      
      // Simulação: Retorno de sucesso (Status 200/201)
      await Future.delayed(const Duration(milliseconds: 500)); // Simula o tempo de rede

      // Simulação de dados retornados pela API:
      final Map<String, dynamic> apiResponse = {
        'id': 'user-${email.split('@').first}',
        'email': email,
        'fullName': 'Usuário Teste AntiBet',
        'token': 'mock-jwt-token-abc123456789',
        'createdAt': DateTime.now().toIso8601String(),
      };

      // 3. Desserializar o JSON para o Modelo
      final user = UserModel.fromJson(apiResponse);

      // 4. Atualizar o estado local e o Stream
      _currentUser = user;
      _userController.add(_currentUser);

      // 5. Simular persistência do token (SharedPreferences/SecureStorage)
      // await StorageService.saveToken(user.token);

      return user;
      
    } catch (e) {
      // Lidar com erros de rede, 401, 403, etc.
      throw Exception('Falha na autenticação: $e');
    }
  }

  /// Simula o processo de logout.
  Future<void> logout() async {
    // 1. Simular chamada de API de logout (opcional)
    await Future.delayed(const Duration(milliseconds: 100));

    // 2. Limpar o estado local e o Stream
    _currentUser = null;
    _userController.add(null);

    // 3. Limpar o token armazenado
    // await StorageService.clearToken();
  }
}