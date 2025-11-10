import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:go_router/go_router.dart';

import 'package:antibet/src/core/notifiers/user_profile_notifier.dart';
import 'package:antibet/src/core/services/user_profile_service.dart';
import 'package:antibet/src/presentation/views/onboarding/register_screen.dart';

// Mocks
class MockUserProfileNotifier extends Mock implements UserProfileNotifier {
  @override
  Future<void> updateProfile(UserProfile newProfile) => super.noSuchMethod(
        Invocation.method(#updateProfile, [newProfile]),
        returnValue: Future.value(null),
      ) as Future<void>;
  
  // Mock para simular o ChangeNotifier
  @override
  void addListener(VoidCallback listener) => super.noSuchMethod(Invocation.method(#addListener, [listener]), returnValue: null);
  @override
  void removeListener(VoidCallback listener) => super.noSuchMethod(Invocation.method(#removeListener, [listener]), returnValue: null);
}

// Helper para o AppRouter (necessário para testar context.go)
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
          path: '/assessment', // Rota de destino após o cadastro
          builder: (context, state) => const Text('Assessment Screen'),
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
      child: const RegisterScreen(),
    ),
  );
}

void main() {
  late MockUserProfileNotifier mockNotifier;

  setUp(() {
    mockNotifier = MockUserProfileNotifier();
  });

  group('RegisterScreen Widget Tests', () {
    testWidgets('All required fields must be present and validate correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(mockNotifier));

      // Verifica a presença de todos os campos
      expect(find.byType(TextFormField), findsNWidgets(2)); // Nickname e Data
      expect(find.text('Nome ou Apelido'), findsOneWidget);
      expect(find.text('Sexo'), findsOneWidget);
      expect(find.text('Há quanto tempo aposta?'), findsOneWidget);
      expect(find.text('Nível de preocupação com apostas (1=Baixo, 5=Alto)'), findsOneWidget);
      
      // Ação: Clicar no botão sem preencher nada
      await tester.tap(find.text('Começar minha jornada'));
      await tester.pump();

      // Verificação: 5 mensagens de erro devem aparecer (1 TextFormField + 4 Dropdowns)
      expect(find.text('Campo obrigatório.'), findsNWidgets(5));
    });

    testWidgets('Successful registration should call updateProfile and navigate', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(mockNotifier));

      // 1. Preenche Apelido
      await tester.enterText(find.byType(TextFormField).first, 'Adonis');

      // 2. Simula seleção de Data (Mock: usa o valor hardcoded no controller para teste)
      final dateController = tester.widget<TextFormField>(find.byType(TextFormField).last).controller;
      dateController!.text = '1988-11';
      await tester.pump();

      // 3. Seleciona Sexo: Feminino
      await tester.tap(find.text('Sexo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Feminino').last);
      await tester.pumpAndSettle();

      // 4. Seleciona Tempo de Aposta: anos
      await tester.tap(find.text('Há quanto tempo aposta?'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Anos').last);
      await tester.pumpAndSettle();

      // 5. Seleciona Nível de Preocupação: 4
      await tester.tap(find.text('Nível de preocupação com apostas (1=Baixo, 5=Alto)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('4').last);
      await tester.pumpAndSettle();

      // Ação: Clicar no botão de registro
      await tester.tap(find.text('Começar minha jornada'));
      await tester.pumpAndSettle();

      // Verificação 1: O método updateProfile deve ser chamado
      final captured = verify(mockNotifier.updateProfile(captureAny)).captured.first as UserProfile;
      
      // Verificação 2: Os dados no objeto UserProfile devem estar corretos
      expect(captured.nickname, 'Adonis');
      expect(captured.gender, 'Feminino');
      expect(captured.birthYearMonth, '1988-11');
      expect(captured.timeBetting, 'anos');
      expect(captured.concernLevel, 4);

      // Verificação 3: Deve navegar para a tela de avaliação
      expect(find.text('Assessment Screen'), findsOneWidget);
    });
  });
}