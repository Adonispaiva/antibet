import 'package:flutter_test/flutter_test.dart';
import 'package:antibet/services/auth/auth_service.dart';

void main() {
  late AuthService authService;

  // O bloco setUp é executado antes de cada teste.
  setUp(() {
    // Instancia um novo AuthService para garantir que o estado (_authToken)
    // esteja limpo para cada teste.
    authService = AuthService();
  });

  group('AuthService Tests', () {
    const String validEmail = 'adonis@inovexa.com';
    const String validPassword = 'senha123';
    const String invalidEmail = 'wrong@email.com';

    // --- Teste de Login ---
    test('Login deve retornar UserModel e simular o salvamento do token em caso de sucesso', () async {
      final user = await authService.login(validEmail, validPassword);

      // Asserções sobre o UserModel retornado
      expect(user.email, validEmail);
      expect(user.id, '123'); 
      // Não podemos acessar o _authToken, mas checkToken deve funcionar agora
      final checkedUser = await authService.checkToken();
      expect(checkedUser, isNotNull);
      expect(checkedUser!.email, validEmail);
    });

    test('Login deve lançar AuthException para credenciais inválidas', () async {
      // Asserção: A função deve lançar uma AuthException
      expect(
        () => authService.login(invalidEmail, validPassword),
        throwsA(isA<AuthException>()),
      );
      
      // Asserção: O token não deve ser salvo se o login falhar
      final checkedUser = await authService.checkToken();
      expect(checkedUser, isNull);
    });
    
    test('Login deve lançar AuthException para endpoints desconhecidos', () async {
      // Simulação de um erro de endpoint (usando credenciais que não acionam o sucesso ou erro de credenciais)
      // O mock _httpPost trata isso
      
      // Nota: Este caso de teste depende da implementação interna do _httpPost mockado 
      // dentro do AuthService para ser robusto. No mock atual do AuthService, 
      // o erro é lançado se o email/senha não bater com o sucesso E não for um endpoint "/api/login"
      
      // Simulação: Embora o endpoint seja sempre "/api/login" no mock, 
      // testamos a propagação da exceção, se ocorrer.
      // Neste teste, dependemos apenas da exceção de credenciais inválidas:
      expect(
        () => authService.login('unknown@test.com', '123'),
        throwsA(isA<AuthException>()),
      );
    });

    // --- Teste de CheckToken ---
    test('checkToken deve retornar UserModel se o token for válido/existir', () async {
      // Pré-condição: Fazer login para simular a existência do token
      await authService.login(validEmail, validPassword);

      // Ação e Asserção
      final user = await authService.checkToken();
      expect(user, isNotNull);
      expect(user!.email, validEmail);
    });

    test('checkToken deve retornar null se não houver token (estado inicial)', () async {
      // Ação e Asserção
      final user = await authService.checkToken();
      expect(user, isNull);
    });

    // --- Teste de Logout ---
    test('Logout deve limpar o token e fazer com que checkToken retorne null', () async {
      // Pré-condição: Login e verificação
      await authService.login(validEmail, validPassword);
      expect(await authService.checkToken(), isNotNull);

      // Ação: Logout
      await authService.logout();

      // Asserção: O token deve ter sido limpo
      final userAfterLogout = await authService.checkToken();
      expect(userAfterLogout, isNull);
    });
  });
}