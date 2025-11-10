// test/services/auth_service_test.dart

import 'package:antibet_mobile/core/models/user_model.dart';
import 'package:antibet_mobile/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // O teste deve ser isolado, por isso usamos uma nova instância do Singleton para cada test suite,
  // embora o Singleton mantenha o estado (o que é uma consideração de arquitetura).
  // Para fins de teste, garantimos que ele está limpo.
  late AuthService authService;

  setUp(() {
    auth// Reseta o estado do serviço (simula um novo início de aplicativo)
    authService = AuthService();
    authService.logout(); 
  });

  group('AuthService Unit Tests', () {
    
    test('Inicialmente, o usuário não deve estar autenticado', () {
      // Assert
      expect(authService.isAuthenticated, isFalse);
      expect(authService.currentUser, isNull);
    });

    test('O login deve autenticar o usuário e retornar um UserModel válido', () async {
      // Arrange
      const String testEmail = 'teste@inovexa.com';
      const String testPassword = 'senha_segura_123';

      // Act
      final user = await authService.login(testEmail, testPassword);

      // Assert
      // 1. Verifica se o objeto retornado é um UserModel
      expect(user, isA<UserModel>());
      // 2. Verifica se o estado de autenticação foi atualizado
      expect(authService.isAuthenticated, isTrue);
      expect(authService.currentUser, isNotNull);
      // 3. Verifica se os dados do usuário no modelo estão corretos (baseados na simulação)
      expect(user.email, equals(testEmail));
      expect(user.fullName, equals('Usuário Teste AntiBet'));
    });

    test('O logout deve desautenticar o usuário e limpar o estado', () async {
      // Arrange: Autentica primeiro
      await authService.login('teste@inovexa.com', 'senha');
      expect(authService.isAuthenticated, isTrue);

      // Act: Desloga
      await authService.logout();

      // Assert
      expect(authService.isAuthenticated, isFalse);
      expect(authService.currentUser, isNull);
    });
    
    test('userChanges stream deve emitir o novo usuário após o login', () async {
      // Arrange
      const String testEmail = 'streamtest@inovexa.com';
      
      // Act & Assert: Espera que o stream emita um UserModel
      expectLater(
        authService.userChanges,
        emitsInOrder([
          isA<UserModel>(), // Após o login
          isNull, // Após o logout
        ]),
      );
      
      // Executa as ações que causam as emissões
      await authService.login(testEmail, 'senha');
      await authService.logout();
    });

  });
}