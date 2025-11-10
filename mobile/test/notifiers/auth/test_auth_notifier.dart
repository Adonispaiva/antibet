import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:antibet/notifiers/auth/auth_notifier.dart';
import 'package:antibet/services/auth/auth_service.dart';
import 'package:antibet/models/user_model.dart';

// 1. Gerar o Mock do AuthService
@GenerateMocks([AuthService])
import 'test_auth_notifier.mocks.dart'; 

void main() {
  late MockAuthService mockAuthService;

  // O bloco setUp é executado antes de cada teste (`test()`).
  setUp(() {
    mockAuthService = MockAuthService();
  });

  group('AuthNotifier Tests', () {
    const UserModel tUser = UserModel(id: '123', email: 'adonis@inovexa.com');

    // --- Teste de Inicialização ---
    test(
        'Deve verificar a sessão inicial e autenticar se o token for encontrado',
        () async {
      // Configuração: Simula que o token é válido
      when(mockAuthService.checkToken())
          .thenAnswer((_) async => tUser); 

      // Ação: Instancia o Notifier, que chama _checkInitialSession no construtor
      final notifier = AuthNotifier(mockAuthService);
      
      // Asserção: Deve começar como loading e terminar autenticado.
      expect(notifier.isLoading, true); // Estado inicial de loading

      // Espera a verificação assíncrona terminar
      await untilCalled(mockAuthService.checkToken()); 
      await Future.delayed(Duration.zero); // Espera o notifyListeners()

      // Asserções finais
      expect(notifier.isAuthenticated, true);
      expect(notifier.currentUser, tUser);
      expect(notifier.isLoading, false);
    });

    test(
        'Deve verificar a sessão inicial e permanecer não autenticado se o token não for encontrado',
        () async {
      // Configuração: Simula que o token não foi encontrado
      when(mockAuthService.checkToken()).thenAnswer((_) async => null);

      // Ação
      final notifier = AuthNotifier(mockAuthService);
      
      // Asserção
      expect(notifier.isLoading, true);

      await untilCalled(mockAuthService.checkToken());
      await Future.delayed(Duration.zero);

      expect(notifier.isAuthenticated, false);
      expect(notifier.currentUser, null);
      expect(notifier.isLoading, false);
    });

    // --- Teste de Login ---
    test('Deve autenticar com sucesso após um login bem-sucedido', () async {
      // Configuração: Simula sucesso do login e retorna o usuário
      when(mockAuthService.login('test@test.com', 'password123'))
          .thenAnswer((_) async => tUser);
      // Configuração para _checkInitialSession não autenticar
      when(mockAuthService.checkToken()).thenAnswer((_) async => null);

      final notifier = AuthNotifier(mockAuthService);
      // Espera a sessão inicial terminar
      await untilCalled(mockAuthService.checkToken()); 

      // Ação: Login
      final future = notifier.login('test@test.com', 'password123');
      
      // Asserção 1: O estado deve mudar para loading
      expect(notifier.isLoading, true);
      
      // Espera o login terminar
      await future; 
      
      // Asserção 2: O estado final
      expect(notifier.isAuthenticated, true);
      expect(notifier.currentUser, tUser);
      expect(notifier.isLoading, false);

      // Verifica se o Service foi chamado corretamente
      verify(mockAuthService.login('test@test.com', 'password123')).called(1);
    });

    test('Deve falhar no login e permanecer não autenticado', () async {
      final tException = AuthException('Credenciais inválidas');
      // Configuração: Simula falha do login
      when(mockAuthService.login(any, any)).thenThrow(tException);
      when(mockAuthService.checkToken()).thenAnswer((_) async => null);

      final notifier = AuthNotifier(mockAuthService);
      await untilCalled(mockAuthService.checkToken());

      // Asserção inicial
      expect(notifier.isAuthenticated, false);
      expect(notifier.currentUser, null);

      // Ação: Login
      await notifier.login('wrong@test.com', 'wrong');

      // Asserção final: Deve permanecer não autenticado
      expect(notifier.isAuthenticated, false);
      expect(notifier.currentUser, null);
      expect(notifier.isLoading, false);
      
      verify(mockAuthService.login('wrong@test.com', 'wrong')).called(1);
    });

    // --- Teste de Logout ---
    test('Deve desautenticar após o logout', () async {
      // Setup: Começa em estado autenticado
      when(mockAuthService.checkToken()).thenAnswer((_) async => tUser);
      when(mockAuthService.logout()).thenAnswer((_) async => {});

      final notifier = AuthNotifier(mockAuthService);
      await untilCalled(mockAuthService.checkToken());

      // Asserção inicial: Deve estar autenticado
      expect(notifier.isAuthenticated, true);

      // Ação: Logout
      final future = notifier.logout();
      
      // Asserção 1: Deve mudar para loading
      expect(notifier.isLoading, true);
      
      await future;

      // Asserção final
      expect(notifier.isAuthenticated, false);
      expect(notifier.currentUser, null);
      expect(notifier.isLoading, false);
      
      // Verifica se o Service foi chamado
      verify(mockAuthService.logout()).called(1);
    });
  });
}