import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:go_router/go_router.dart';

import 'package:antibet/src/core/notifiers/open_banking_notifier.dart';
import 'package:antibet/src/presentation/views/finance/open_banking_view.dart';

// Mocks
class MockOpenBankingNotifier extends Mock implements OpenBankingNotifier {
  @override
  bool get isConnected => super.noSuchMethod(
        Invocation.getter(#isConnected),
        returnValue: false,
      ) as bool;

  @override
  bool get isLoading => super.noSuchMethod(
        Invocation.getter(#isLoading),
        returnValue: false,
      ) as bool;

  @override
  Future<bool> connectBank() => super.noSuchMethod(
        Invocation.method(#connectBank, []),
        returnValue: Future.value(false),
      ) as Future<bool>;

  @override
  Future<void> disconnectBank() => super.noSuchMethod(
        Invocation.method(#disconnectBank, []),
        returnValue: Future.value(null),
      ) as Future<void>;
      
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
    // Configura um GoRouter com rotas de destino simuladas
    return GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => child), // Tela sob teste
        GoRoute(path: '/finance', builder: (context, state) => const Text('Finance Panel')),
      ],
    ).createRouterWidget(context);
  }
}

Widget createWidgetUnderTest(MockOpenBankingNotifier mockNotifier) {
  return MaterialApp(
    home: MockGoRouterProvider(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<OpenBankingNotifier>.value(value: mockNotifier),
        ],
        child: Builder( // Adiciona Builder para garantir que o contexto tenha um Scaffold/Navigator
          builder: (context) => const OpenBankingView(),
        ),
      ),
    ),
  );
}

void main() {
  late MockOpenBankingNotifier mockNotifier;

  setUp(() {
    mockNotifier = MockOpenBankingNotifier();
  });

  group('OpenBankingView Widget Tests', () {
    testWidgets('Should display initial disconnected state and connect button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(mockNotifier));
      
      // Estado Inicial: Desconectado
      expect(find.text('Desconectado'), findsOneWidget);
      expect(find.text('Conectar Minha Conta Bancária'), findsOneWidget);
      expect(find.text('Desconectar / Revogar Acesso'), findsNothing);
      expect(find.text('Segurança e LGPD'), findsOneWidget);
    });

    testWidgets('Should successfully connect and navigate to finance panel', (WidgetTester tester) async {
      // Setup: Mocka a conexão para retornar sucesso
      when(mockNotifier.connectBank()).thenAnswer((_) => Future.value(true));
      
      await tester.pumpWidget(createWidgetUnderTest(mockNotifier));
      
      // 1. Ação: Toca no botão Conectar
      await tester.tap(find.text('Conectar Minha Conta Bancária'));
      await tester.pump(); // Inicia o Future
      
      // 2. Mocka o estado de carregamento (opcional, mas bom para simulação)
      when(mockNotifier.isLoading).thenReturn(true);
      await tester.pump(const Duration(milliseconds: 50)); 
      
      // 3. Espera o Future e a navegação
      await tester.pumpAndSettle();

      // Verificação 1: O método de conexão deve ser chamado
      verify(mockNotifier.connectBank()).called(1);
      
      // Verificação 2: Deve mostrar o SnackBar de sucesso
      expect(find.text('Conexão bem-sucedida! Seus dados financeiros foram carregados.'), findsOneWidget);
      
      // Verificação 3: Deve navegar para o Painel Financeiro
      expect(find.text('Finance Panel'), findsOneWidget);
    });

    testWidgets('Should handle connection failure and show error message', (WidgetTester tester) async {
      // Setup: Mocka a conexão para retornar falha
      when(mockNotifier.connectBank()).thenAnswer((_) => Future.value(false));
      
      await tester.pumpWidget(createWidgetUnderTest(mockNotifier));
      
      // 1. Ação: Toca no botão Conectar
      await tester.tap(find.text('Conectar Minha Conta Bancária'));
      await tester.pumpAndSettle(); 

      // Verificação: Deve mostrar o SnackBar de falha
      expect(find.text('Falha na conexão. Tente novamente ou verifique suas credenciais.'), findsOneWidget);
      
      // Deve permanecer na tela de Open Banking
      expect(find.text('Conexão Open Banking'), findsOneWidget);
    });

    testWidgets('Should handle disconnect bank flow', (WidgetTester tester) async {
      // Setup: Simula o estado conectado
      when(mockNotifier.isConnected).thenReturn(true);
      
      await tester.pumpWidget(createWidgetUnderTest(mockNotifier));
      await tester.pumpAndSettle(); // Redesenha com o estado conectado

      // 1. Verifica o estado e o botão de desconexão
      expect(find.text('Conectado e Dados Carregados'), findsOneWidget);
      expect(find.text('Desconectar / Revogar Acesso'), findsOneWidget);
      
      // 2. Ação: Toca no botão Desconectar
      await tester.tap(find.text('Desconectar / Revogar Acesso'));
      await tester.pump();
      
      // Verificação 1: O método de desconexão deve ser chamado
      verify(mockNotifier.disconnectBank()).called(1);
      
      // Verificação 2: Deve mostrar o SnackBar de revogação
      await tester.pump(); 
      expect(find.text('Conexão bancária revogada com sucesso.'), findsOneWidget);
    });

    testWidgets('Should display CircularProgressIndicator when loading', (WidgetTester tester) async {
      // Setup: Simula o estado de carregamento
      when(mockNotifier.isLoading).thenReturn(true);
      
      await tester.pumpWidget(createWidgetUnderTest(mockNotifier));
      await tester.pumpAndSettle();

      // Verifica o indicador de carregamento
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // O botão de conexão/desconexão não deve estar ativo
      expect(find.widgetWithText(ElevatedButton, 'Conectar Minha Conta Bancária'), findsNothing);
    });
  });
}