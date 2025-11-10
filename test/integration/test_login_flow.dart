import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:antibet/notifiers/auth/auth_notifier.dart';
import 'package:antibet/notifiers/lockdown/lockdown_notifier.dart'; // Assume-se a existência
import 'package:antibet/services/auth/auth_service.dart'; // Mocado
import 'package:antibet/models/user_model.dart'; // Mocado
import 'package:antibet/router/app_router.dart'; // Mocado ou usado

// Reutilizamos o MockService do teste unitário
import '../notifiers/auth/test_auth_notifier.mocks.dart'; 

// --- Configuração de Mock para o Teste de Integração ---

/// Cria um widget wrapper para simular o AppRouter e os Providers
Widget createTestWidget({
  required AuthNotifier authNotifier,
  required LockdownNotifier lockdownNotifier,
}) {
  // Mockamos o AppRouter para focar apenas na lógica do Provider/UI.
  // Em um teste de integração real, usaríamos o AppRouter configurado.
  // Aqui, simulamos o nível de Providers do main.dart.
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthNotifier>.value(value: authNotifier),
      // Adicionamos o LockdownNotifier mockado para satisfazer o AppRouter/UI
      ChangeNotifierProvider<LockdownNotifier>.value(value: lockdownNotifier), 
    ],
    child: Builder(
      builder: (context) {
        // Mockamos o roteamento para focar na transição de telas
        final appRouter = AppRouter(
          authNotifier: context.read<AuthNotifier>(),
          lockdownNotifier: context.read<LockdownNotifier>(),
          // Se o GoRouter fosse necessário, seria inicializado aqui.
        );
        
        // Simulação do MaterialApp.router com a tela inicial baseada no estado
        return MaterialApp(
          home: AnimatedBuilder(
            animation: authNotifier,
            builder: (context, _) {
              if (authNotifier.isLoading) {
                return const Center(child: Text('Loading Screen'));
              }
              if (authNotifier.isAuthenticated) {
                // Mock: Se autenticado, vai para a HomeScreen (que deve estar em lib/ui/home/home_screen.dart)
                return const Text('HomeScreen - Logado'); 
              }
              // Mock: Se não autenticado, vai para a LoginScreen (que deve estar em lib/ui/login/login_screen.dart)
              return const Text('LoginScreen - Deslogado'); 
            },
          ),
        );
      },
    ),
  );
}


void main() {
  // Mocks necessários
  late MockAuthService mockAuthService;
  late AuthNotifier authNotifier;
  late LockdownNotifier mockLockdownNotifier;

  const UserModel tUser = UserModel(id: '123', email: 'adonis@inovexa.com');
  const String validEmail = 'adonis@inovexa.com';
  const String validPassword = 'senha123';

  // O bloco setUp é executado antes de cada teste
  setUp(() {
    mockAuthService = MockAuthService();
    // Simula que a sessão inicial está limpa (não logado)
    when(mockAuthService.checkToken()).thenAnswer((_) async => null);
    
    // Inicializa o Notifier, que chama o checkToken acima
    authNotifier = AuthNotifier(mockAuthService);
    
    // Mock simples para o Notifier de Bloqueio, que é uma dependência do AppRouter no main.dart
    // Em um teste real, precisaríamos de um MockLockdownNotifier
    mockLockdownNotifier = LockdownNotifier(null); // Mock simples com null para o service
  });
  
  // Espera a verificação inicial assíncrona terminar
  Future<void> waitForInitialCheck(WidgetTester tester) async {
    // Espera até que o checkToken seja chamado
    await untilCalled(mockAuthService.checkToken()); 
    // Espera por um frame para o notifyListeners ser processado
    await tester.pumpAndSettle(); 
  }


  group('Integration: Login/Logout Flow (UI <-> Notifier)', () {
    
    testWidgets('1. Deve mostrar LoginScreen e transicionar para HomeScreen após o sucesso', (WidgetTester tester) async {
      
      // 1. Setup inicial e Asserção (Antes do Login)
      await tester.pumpWidget(createTestWidget(authNotifier: authNotifier, lockdownNotifier: mockLockdownNotifier));
      
      // Espera o carregamento inicial terminar
      await waitForInitialCheck(tester);
      
      // Asserção: Deve estar na tela de Login (Texto "LoginScreen - Deslogado")
      expect(find.text('LoginScreen - Deslogado'), findsOneWidget);
      expect(find.text('HomeScreen - Logado'), findsNothing);


      // 2. Configura o Mock para Login de Sucesso
      when(mockAuthService.login(validEmail, validPassword))
          .thenAnswer((_) async => tUser);


      // 3. Simula a Ação de Login (Chamando o Notifier)
      // Nota: Não temos a UI completa, simulamos a chamada direta do Notifier 
      // que a UI faria (como implementado no login_screen.dart).
      await authNotifier.login(validEmail, validPassword);

      // Espera o login assíncrono terminar e o notifyListeners ser processado
      await tester.pumpAndSettle(); 


      // 4. Asserção Final (Após o Login)
      // Verifica se o Notifier está no estado correto
      expect(authNotifier.isAuthenticated, true);
      
      // Asserção: Deve transicionar para a tela Home (Texto "HomeScreen - Logado")
      expect(find.text('LoginScreen - Deslogado'), findsNothing);
      expect(find.text('HomeScreen - Logado'), findsOneWidget);
      
      verify(mockAuthService.login(validEmail, validPassword)).called(1);
    });

    testWidgets('2. Deve mostrar HomeScreen e retornar para LoginScreen após o logout', (WidgetTester tester) async {
      
      // 1. Setup: Começa em estado Autenticado
      when(mockAuthService.checkToken()).thenAnswer((_) async => tUser);
      when(mockAuthService.logout()).thenAnswer((_) async => {}); // Configura o mock para logout
      
      // Instancia um novo Notifier que começará logado
      final loggedInNotifier = AuthNotifier(mockAuthService); 
      
      await tester.pumpWidget(createTestWidget(authNotifier: loggedInNotifier, lockdownNotifier: mockLockdownNotifier));
      
      // Espera o carregamento inicial (que agora resulta em login)
      await waitForInitialCheck(tester); 
      
      // Asserção: Deve estar logado
      expect(find.text('HomeScreen - Logado'), findsOneWidget);


      // 2. Simula a Ação de Logout (Chamando o Notifier)
      await loggedInNotifier.logout();

      // Espera o logout assíncrono terminar e o notifyListeners ser processado
      await tester.pumpAndSettle(); 


      // 3. Asserção Final
      // Verifica se o Notifier está no estado correto
      expect(loggedInNotifier.isAuthenticated, false);
      
      // Asserção: Deve transicionar de volta para a tela de Login
      expect(find.text('HomeScreen - Logado'), findsNothing);
      expect(find.text('LoginScreen - Deslogado'), findsOneWidget);

      verify(mockAuthService.logout()).called(1);
    });
  });
}