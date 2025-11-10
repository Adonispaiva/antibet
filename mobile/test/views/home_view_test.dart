import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Importações dos componentes a serem testados e dependências
import 'package:antibet_mobile/core/domain/user_model.dart';
import 'package:antibet_mobile/notifiers/auth_notifier.dart';
import 'package:antibet_mobile/presentation/views/home_view.dart';

// Gera o mock para o AuthNotifier (reutilizando a geração)
@GenerateMocks([AuthNotifier])
import 'home_view_test.mocks.dart';

void main() {
  late MockAuthNotifier mockAuthNotifier;
  const UserModel testUser = UserModel(id: '123', email: 'orion@inovexa.com.br');

  setUp(() {
    mockAuthNotifier = MockAuthNotifier();
    // Configura o estado padrão para a HomeView
    when(mockAuthNotifier.state).thenReturn(AuthState.authenticated);
    when(mockAuthNotifier.isAuthenticated).thenReturn(true);
    when(mockAuthNotifier.currentUser).thenReturn(testUser);
  });

  // Widget Wrapper que simula o ambiente da aplicação (MaterialApp e Provider)
  Widget createHomeScreen({required AuthNotifier mockNotifier}) {
    return MaterialApp(
      home: ChangeNotifierProvider<AuthNotifier>.value(
        value: mockNotifier,
        child: const HomeView(),
      ),
    );
  }

  group('HomeView Widget Tests', () {

    // Helper para encontrar o botão de Logout
    Finder findLogoutButton() => find.widgetWithText(ElevatedButton, 'Logout');

    // --- Teste 1: Exibição Correta do Usuário ---
    testWidgets('HomeView exibe a mensagem de boas-vindas e o email do usuário', (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen(mockNotifier: mockAuthNotifier));

      // Verifica o título e a mensagem de boas-vindas
      expect(find.text('Home Screen - AntiBet Mobile'), findsOneWidget);
      expect(find.text('Bem-vindo à área logada!'), findsOneWidget);

      // Verifica a exibição do email do usuário mockado
      expect(find.text('Usuário: ${testUser.email}'), findsOneWidget);
    });

    // --- Teste 2: Exibição de Usuário Desconhecido (Placeholder) ---
    testWidgets('HomeView exibe "Usuário Desconhecido" se currentUser for nulo', (WidgetTester tester) async {
      // Configura o mock para retornar null no currentUser
      when(mockAuthNotifier.currentUser).thenReturn(null);

      await tester.pumpWidget(createHomeScreen(mockNotifier: mockAuthNotifier));

      // Verifica a exibição do placeholder
      expect(find.text('Usuário Desconhecido'), findsOneWidget);
    });

    // --- Teste 3: Chamada do Logout ---
    testWidgets('Tocar no botão de Logout chama AuthNotifier.logout()', (WidgetTester tester) async {
      // Configuração do mock para simular sucesso no logout
      when(mockAuthNotifier.logout()).thenAnswer((_) async {});
      
      await tester.pumpWidget(createHomeScreen(mockNotifier: mockAuthNotifier));

      // Toca no botão de Logout
      await tester.tap(findLogoutButton());
      await tester.pump(); 

      // Verifica se o método correto foi chamado no Notifier
      verify(mockAuthNotifier.logout()).called(1);
      
      // Nota: A navegação para LoginView é tratada pelo AuthGate, não por HomeView, o que é testado em outro lugar.
    });
  });
}