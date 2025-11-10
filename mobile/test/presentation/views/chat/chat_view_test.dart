import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:go_router/go_router.dart';

import 'package:antibet/src/core/notifiers/user_profile_notifier.dart';
import 'package:antibet/src/core/services/user_profile_service.dart'; // Import necessário para UserProfile
import 'package:antibet/src/presentation/views/chat/chat_view.dart';

// Constantes
const String _iaName = 'AntiBet Coach';

// Mocks
class MockUserProfileNotifier extends Mock implements UserProfileNotifier {
  @override
  String get nickname => super.noSuchMethod(
        Invocation.getter(#nickname),
        returnValue: 'Adonis', // Nome padrão para o teste
      ) as String;
  
  // Mock para simular o ChangeNotifier
  @override
  void addListener(VoidCallback listener) => super.noSuchMethod(Invocation.method(#addListener, [listener]), returnValue: null);
  @override
  void removeListener(VoidCallback listener) => super.noSuchMethod(Invocation.method(#removeListener, [listener]), returnValue: null);

  @override
  UserProfile get profile => super.noSuchMethod(
        Invocation.getter(#profile),
        returnValue: UserProfile(nickname: 'Adonis'),
      ) as UserProfile;
}

// Helper para o AppRouter (necessário para testar a navegação)
class MockGoRouterProvider extends StatelessWidget {
  const MockGoRouterProvider({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => child,
        ),
        GoRoute(
          path: '/chat/limits', // Rota de destino simulada do botão Info
          builder: (context, state) => const Text('Limits Screen'),
        ),
      ],
    ).createRouterWidget(context);
  }
}

Widget createWidgetUnderTest(MockUserProfileNotifier mockNotifier) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserProfileNotifier>.value(value: mockNotifier),
    ],
    child: MockGoRouterProvider(
      child: const ChatView(),
    ),
  );
}

void main() {
  late MockUserProfileNotifier mockNotifier;

  setUp(() {
    mockNotifier = MockUserProfileNotifier();
    // Garante que o nickname mockado será usado
    when(mockNotifier.nickname).thenReturn('Adonis');
  });

  group('ChatView Widget Tests', () {
    testWidgets('Should display initial message personalized with user name', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(mockNotifier));
      
      // Espera o initState (Future.delayed não é usado no initState para a primeira mensagem)
      await tester.pumpAndSettle();

      // Verifica o título e o nome da IA
      expect(find.text('Chat com AntiBet Coach'), findsOneWidget);
      expect(find.text(_iaName), findsOneWidget);
      
      // Verifica a mensagem inicial personalizada (usando o mock 'Adonis')
      expect(find.textContaining('Olá, Adonis. Como você está se sentindo hoje?'), findsOneWidget);
    });

    testWidgets('Should handle user input and display user message', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(mockNotifier));
      await tester.pumpAndSettle();

      final inputField = find.byType(TextField);
      expect(inputField, findsOneWidget);
      
      const userMessage = 'Estou com muita vontade de apostar.';
      
      // Ação 1: Digitar a mensagem
      await tester.enterText(inputField, userMessage);
      
      // Ação 2: Clicar no botão de enviar
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump(); // Atualiza a tela para exibir a mensagem do usuário

      // Verificação 1: A mensagem do usuário deve aparecer (bolha)
      expect(find.text(userMessage), findsOneWidget);
      
      // Verificação 2: O campo de input deve estar limpo
      expect(find.text('Estou com muita vontade de apostar.'), findsNothing);
    });
    
    testWidgets('Should display IA response after a short delay', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(mockNotifier));
      await tester.pumpAndSettle();

      // Envia a mensagem do usuário
      await tester.enterText(find.byType(TextField), 'Teste de resposta IA');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump(); // Mensagem do usuário aparece
      
      // Espera o Future.delayed (1 segundo) que simula a resposta da IA
      await tester.pump(const Duration(seconds: 2)); 

      // Verifica a resposta simulada da IA
      expect(find.textContaining('Entendo o que você está sentindo.'), findsOneWidget);
    });

    testWidgets('Tapping the info button should navigate to limits screen', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(mockNotifier));
      await tester.pumpAndSettle();

      final infoButton = find.byIcon(Icons.info_outline);
      expect(infoButton, findsOneWidget);

      // Ação: Tocar no botão
      await tester.tap(infoButton);
      await tester.pumpAndSettle();

      // Verificação: Deve navegar para a rota simulada
      expect(find.text('Limits Screen'), findsOneWidget);
    });
  });
}