import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:antibet_mobile/models/user_model.dart';
import 'package:antibet_mobile/infra/services/auth_service.dart';
import 'package:antibet_mobile/notifiers/auth_notifier.dart';

// =========================================================================
// SIMULAÇÃO DE DEPENDÊNCIAS (Mocks)
// =========================================================================

// Simulação de User Model (mínimo necessário para o teste)
class UserModel {
  final String id;
  final String email;
  final String? name;
  final DateTime? createdAt;
  UserModel({required this.id, required this.email, this.name, this.createdAt});
  factory UserModel.fromJson(Map<String, dynamic> json) => throw UnimplementedError();
  UserModel copyWith({String? id, String? email, String? name, DateTime? createdAt}) => this;
}

// Simulação de AuthStatus (mínimo necessário para o teste)
enum AuthStatus {
  uninitialized, // Estado inicial, checando
  loading,       // Carregando (ex: durante login)
  authenticated, // Autenticado
  unauthenticated  // Não autenticado
}

// Simulação de AuthService (mínimo necessário para o teste)
class AuthService {
  AuthService(dynamic storageService);
  Future<UserModel> login(String email, String password) async => throw UnimplementedError();
  Future<UserModel> register(String name, String email, String password) async => throw UnimplementedError();
  Future<UserModel?> checkAuthStatus() async => throw UnimplementedError();
  Future<void> logout() async => throw UnimplementedError();
}

// Mock da classe de Serviço de Autenticação
class MockAuthService implements AuthService {
  MockAuthService();
  bool loginShouldFail = false;
  bool registerShouldFail = false;
  bool checkStatusShouldBeNull = false;
  
  final mockUser = UserModel(id: 'u001', email: 'test@inovexa.com', name: 'Test User');

  @override
  Future<UserModel> login(String email, String password) async {
    if (loginShouldFail) {
      throw Exception('Credenciais inválidas');
    }
    await Future.delayed(Duration.zero);
    return mockUser;
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    if (registerShouldFail) {
      throw Exception('E-mail já cadastrado.');
    }
    await Future.delayed(Duration.zero);
    return mockUser;
  }

  @override
  Future<UserModel?> checkAuthStatus() async {
    if (checkStatusShouldBeNull) {
      return null;
    }
    await Future.delayed(Duration.zero);
    return mockUser;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(Duration.zero);
  }
  
  @override
  AuthService(dynamic storageService) {}
}

// SIMULAÇÃO DO AUTH NOTIFIER (mínimo necessário para o teste)
class AuthNotifier with ChangeNotifier {
  final MockAuthService _authService;
  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _user;
  String? _errorMessage;

  AuthNotifier(this._authService) {
    checkAuthStatus();
  }

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _setStatus(AuthStatus.loading);
    try {
      final user = await _authService.login(email, password);
      _user = user;
      _setStatus(AuthStatus.authenticated);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _setStatus(AuthStatus.loading);
    try {
      final user = await _authService.register(name, email, password);
      _user = user;
      _setStatus(AuthStatus.authenticated);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }

  Future<void> checkAuthStatus() async {
    _setStatus(AuthStatus.loading);
    try {
      final user = await _authService.checkAuthStatus();
      if (user != null) {
        _user = user;
        _setStatus(AuthStatus.authenticated);
      } else {
        _user = null;
        _setStatus(AuthStatus.unauthenticated);
      }
    } catch (e) {
      _user = null;
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  Future<void> logout() async {
    _setStatus(AuthStatus.loading);
    try {
      await _authService.logout();
      _user = null;
      _setStatus(AuthStatus.unauthenticated);
    } catch (e) {
      _user = null;
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  void _setStatus(AuthStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      notifyListeners();
    }
  }
}

// =========================================================================
// FIM DA SIMULAÇÃO
// =========================================================================

void main() {
  group('AuthNotifier Unit Tests', () {
    late AuthNotifier authNotifier;
    late MockAuthService mockAuthService;

    // Configuração: Garante estado limpo e objetos antes de cada teste
    setUp(() {
      mockAuthService = MockAuthService();
      // O construtor chama checkAuthStatus, então precisamos controlar o mock antes
      mockAuthService.checkStatusShouldBeNull = true; // Simula estado deslogado inicial
      authNotifier = AuthNotifier(mockAuthService);
    });
    
    // Testa o fluxo de inicialização
    test('01. Deve inicializar como unauthenticated se checkAuthStatus falhar', () async {
      // Damos tempo para o construtor rodar o checkAuthStatus
      await Future.microtask(() => null); 
      expect(authNotifier.status, AuthStatus.unauthenticated);
      expect(authNotifier.user, isNull);
    });

    // ---------------------------------------------------------------------
    // Testes de Login
    // ---------------------------------------------------------------------
    test('02. Login deve atualizar status para authenticated em caso de sucesso', () async {
      final listenerCallCount = <AuthStatus>[];
      authNotifier.addListener(() => listenerCallCount.add(authNotifier.status));

      mockAuthService.loginShouldFail = false;
      final success = await authNotifier.login('any@email.com', 'anypass');

      expect(success, isTrue);
      expect(authNotifier.status, AuthStatus.authenticated);
      expect(authNotifier.user, isNotNull);
      // Espera-se [loading, authenticated]
      expect(listenerCallCount, [AuthStatus.loading, AuthStatus.authenticated]);
    });

    test('03. Login deve atualizar status para unauthenticated em caso de falha', () async {
      mockAuthService.loginShouldFail = true;
      final success = await authNotifier.login('wrong@email.com', 'wrongpass');

      expect(success, isFalse);
      expect(authNotifier.status, AuthStatus.unauthenticated);
      expect(authNotifier.user, isNull);
      expect(authNotifier.errorMessage, 'Credenciais inválidas');
    });

    // ---------------------------------------------------------------------
    // Testes de Registro
    // ---------------------------------------------------------------------
    test('04. Register deve atualizar status para authenticated em caso de sucesso', () async {
      mockAuthService.registerShouldFail = false;
      final success = await authNotifier.register('Name', 'new@email.com', 'pass');

      expect(success, isTrue);
      expect(authNotifier.status, AuthStatus.authenticated);
      expect(authNotifier.user, isNotNull);
    });

    test('05. Register deve atualizar status para unauthenticated em caso de falha', () async {
      mockAuthService.registerShouldFail = true;
      final success = await authNotifier.register('Name', 'exists@email.com', 'pass');

      expect(success, isFalse);
      expect(authNotifier.status, AuthStatus.unauthenticated);
      expect(authNotifier.user, isNull);
      expect(authNotifier.errorMessage, 'E-mail já cadastrado.');
    });

    // ---------------------------------------------------------------------
    // Testes de Status e Logout
    // ---------------------------------------------------------------------
    test('06. checkAuthStatus deve autenticar e preencher o usuário se o token for válido', () async {
      // Garante que o estado inicial do construtor seja resolvido primeiro
      await Future.microtask(() => null); 
      
      mockAuthService.checkStatusShouldBeNull = false;
      await authNotifier.checkAuthStatus();

      expect(authNotifier.status, AuthStatus.authenticated);
      expect(authNotifier.user, isNotNull);
    });

    test('07. checkAuthStatus deve desautenticar se o token for inválido/nulo', () async {
      // Garante que o estado inicial do construtor seja resolvido primeiro
      await Future.microtask(() => null); 

      mockAuthService.checkStatusShouldBeNull = true;
      await authNotifier.checkAuthStatus();

      expect(authNotifier.status, AuthStatus.unauthenticated);
      expect(authNotifier.user, isNull);
    });

    test('08. Logout deve atualizar status para unauthenticated e limpar o usuário', () async {
      // Prepara o Notifier como logado (simulando um login bem-sucedido)
      mockAuthService.loginShouldFail = false;
      await authNotifier.login('any@email.com', 'anypass');
      expect(authNotifier.status, AuthStatus.authenticated);

      await authNotifier.logout();

      expect(authNotifier.status, AuthStatus.unauthenticated);
      expect(authNotifier.user, isNull);
    });
  });
}