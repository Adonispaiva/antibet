import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Importações dos componentes a serem testados e dependências
import 'package:antibet_mobile/core/domain/user_model.dart';
import 'package:antibet_mobile/infra/services/auth_service.dart';
import 'package:antibet_mobile/notifiers/auth_notifier.dart';

// Gera o mock para o AuthService
@GenerateMocks([AuthService])
import 'auth_notifier_test.mocks.dart'; 

void main() {
  late MockAuthService mockAuthService;
  late AuthNotifier authNotifier;

  const UserModel testUser = UserModel(id: '1', email: 'test@antibet.com');
  const AuthException authError = AuthException('Credenciais inválidas.');

  // Configuração executada antes de cada teste
  setUp(() {
    mockAuthService = MockAuthService();
    // Injeta o mock no AuthNotifier
    authNotifier = AuthNotifier(mockAuthService); 
  });

  // Limpeza executada após cada teste
  tearDown(() {
    // Garante que não haja interações pendentes ou estados sujos
    reset(mockAuthService);
  });

  group('AuthNotifier Tests', () {
    // --- Teste 1: Estado Inicial ---
    test('Estado inicial é AuthState.initial', () {
      expect(authNotifier.state, AuthState.initial);
      expect(authNotifier.currentUser, isNull);
      expect(authNotifier.isAuthenticated, isFalse);
    });

    // --- Teste 2: checkAuthenticationStatus (Token Encontrado) ---
    test('checkAuthenticationStatus: autentica se token existir', () async {
      // Configuração: AuthService retorna true para token armazenado
      when(mockAuthService.isTokenStored()).thenAnswer((_) async => true);
      
      // Ouve as transições de estado
      final listener = MockAuthListener();
      authNotifier.addListener(listener);

      await authNotifier.checkAuthenticationStatus();

      // Verifica as transições de estado: initial -> loading -> authenticated
      verify(listener.call()).called(2); 
      expect(authNotifier.state, AuthState.authenticated);
      expect(authNotifier.isAuthenticated, isTrue);
      expect(authNotifier.currentUser, isNotNull); // Verificação do placeholder
      verify(mockAuthService.isTokenStored()).called(1);
    });

    // --- Teste 3: checkAuthenticationStatus (Token Não Encontrado) ---
    test('checkAuthenticationStatus: desautentica se token não existir', () async {
      // Configuração: AuthService retorna false para token armazenado
      when(mockAuthService.isTokenStored()).thenAnswer((_) async => false);

      await authNotifier.checkAuthenticationStatus();

      // Verifica o estado final
      expect(authNotifier.state, AuthState.unauthenticated);
      expect(authNotifier.isAuthenticated, isFalse);
      verify(mockAuthService.isTokenStored()).called(1);
    });

    // --- Teste 4: Login Bem-Sucedido ---
    test('login: sucesso autentica e define o usuário', () async {
      // Configuração: AuthService retorna um UserModel no login
      when(mockAuthService.login('valid@test.com', 'password')).thenAnswer((_) async => testUser);

      await authNotifier.login('valid@test.com', 'password');

      // Verifica o estado final
      expect(authNotifier.state, AuthState.authenticated);
      expect(authNotifier.currentUser, testUser);
      expect(authNotifier.isAuthenticated, isTrue);
      verify(mockAuthService.login('valid@test.com', 'password')).called(1);
    });

    // --- Teste 5: Login Mal-Sucedido ---
    test('login: falha não autentica, define erro e re-lança exceção', () async {
      // Configuração: AuthService lança AuthException no login
      when(mockAuthService.login('invalid@test.com', 'wrong')).thenThrow(authError);
      
      // Deve lançar a exceção
      expect(() => authNotifier.login('invalid@test.com', 'wrong'), throwsA(isA<AuthException>()));

      // Verifica o estado final (após o catch/finally interno)
      expect(authNotifier.state, AuthState.unauthenticated);
      expect(authNotifier.isAuthenticated, isFalse);
      expect(authNotifier.errorMessage, isNotNull);
    });

    // --- Teste 6: Registro Bem-Sucedido (com login automático) ---
    test('register: sucesso autentica e define o usuário', () async {
      // Configuração: AuthService retorna um UserModel no registro
      when(mockAuthService.register('new@user.com', 'newpass')).thenAnswer((_) async => testUser);

      await authNotifier.register('new@user.com', 'newpass');

      // Verifica o estado final (registro bem-sucedido implica login automático)
      expect(authNotifier.state, AuthState.authenticated);
      expect(authNotifier.currentUser, testUser);
      verify(mockAuthService.register('new@user.com', 'newpass')).called(1);
    });

    // --- Teste 7: Logout Bem-Sucedido ---
    test('logout: desautentica e limpa o usuário', () async {
      // Configuração inicial (simula que já está logado)
      when(mockAuthService.isTokenStored()).thenAnswer((_) async => true);
      await authNotifier.checkAuthenticationStatus(); // Estado -> authenticated
      
      // Execução do Logout
      when(mockAuthService.logout()).thenAnswer((_) async {});
      await authNotifier.logout();

      // Verifica o estado final
      expect(authNotifier.state, AuthState.unauthenticated);
      expect(authNotifier.currentUser, isNull);
      expect(authNotifier.isAuthenticated, isFalse);
      verify(mockAuthService.logout()).called(1);
    });
  });
}

// Classe de mock simples para o Listener do ChangeNotifier
class MockAuthListener extends Mock {
  void call();
}