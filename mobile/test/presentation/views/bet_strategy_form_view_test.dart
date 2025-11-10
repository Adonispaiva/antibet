import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Importações dos componentes a serem testados e dependências
import 'package:antibet_mobile/core/domain/bet_strategy_model.dart';
import 'package:antibet_mobile/infra/services/bet_strategy_service.dart';
import 'package:antibet_mobile/notifiers/bet_strategy_notifier.dart';
import 'package:antibet_mobile/presentation/views/bet_strategy_form_view.dart';

// Gera o mock para o BetStrategyNotifier
@GenerateMocks([BetStrategyNotifier])
import 'bet_strategy_form_view_test.mocks.dart'; 

void main() {
  late MockBetStrategyNotifier mockNotifier;

  const BetStrategyModel existingStrategy = BetStrategyModel(
    id: 's1',
    name: 'Regra de Limite Diário',
    description: 'Não apostar após a terceira perda no dia.',
    riskFactor: 0.1, // Representado como 10% no formulário
    isActive: true,
  );

  setUp(() {
    mockNotifier = MockBetStrategyNotifier();
    // Configura o mock do método saveStrategy para sucesso
    when(mockNotifier.saveStrategy(any)).thenAnswer((_) async {});
  });

  // Widget Wrapper que simula o ambiente da aplicação (MaterialApp e Provider)
  Widget createFormScreen({required BetStrategyNotifier notifier, BetStrategyModel? strategy}) {
    // Usamos um Builder para simular o contexto de navegação necessário para o pop()
    return MaterialApp(
      home: Builder(
        builder: (context) => ChangeNotifierProvider<BetStrategyNotifier>.value(
          value: notifier,
          child: BetStrategyFormView(strategy: strategy),
        ),
      ),
    );
  }

  group('BetStrategyFormView Tests', () {
    
    // Helpers para encontrar campos
    Finder findNameField() => find.widgetWithText(TextFormField, 'Nome da Estratégia');
    Finder findRiskField() => find.widgetWithText(TextFormField, 'Fator de Risco (%)');
    Finder findSaveButton() => find.widgetWithText(ElevatedButton, 'Criar Estratégia');
    Finder findSaveEditButton() => find.widgetWithText(ElevatedButton, 'Salvar Alterações');

    // --- Teste 1: Modo Criação (Inicialização) ---
    testWidgets('Inicia no modo Criação com título e botão corretos', (WidgetTester tester) async {
      await tester.pumpWidget(createFormScreen(notifier: mockNotifier));

      expect(find.text('Nova Estratégia'), findsOneWidget);
      expect(findSaveButton(), findsOneWidget);
      expect(findSaveEditButton(), findsNothing);
      expect(tester.widget<TextFormField>(findRiskField()).controller!.text, isEmpty);
    });

    // --- Teste 2: Modo Edição (Inicialização) ---
    testWidgets('Inicia no modo Edição com dados preenchidos', (WidgetTester tester) async {
      await tester.pumpWidget(createFormScreen(notifier: mockNotifier, strategy: existingStrategy));

      expect(find.text('Editar Estratégia'), findsOneWidget);
      expect(findSaveButton(), findsNothing);
      expect(findSaveEditButton(), findsOneWidget);
      
      // Verifica se os dados do modelo foram carregados (0.1 * 100 = 10%)
      expect(tester.widget<TextFormField>(findNameField()).controller!.text, 'Regra de Limite Diário');
      expect(tester.widget<TextFormField>(findRiskField()).controller!.text, '10');
    });

    // --- Teste 3: Validação de Campos Vazios ---
    testWidgets('Submissão falha se o nome estiver vazio', (WidgetTester tester) async {
      await tester.pumpWidget(createFormScreen(notifier: mockNotifier));
      
      // Limpa todos os campos
      await tester.enterText(findNameField(), '');
      await tester.enterText(findRiskField(), '50');

      await tester.tap(findSaveButton());
      await tester.pump(); // Mostra erro

      expect(find.text('O nome é obrigatório'), findsOneWidget);
      verifyNever(mockNotifier.saveStrategy(any));
    });

    // --- Teste 4: Validação de Risco Inválido ---
    testWidgets('Submissão falha se o risco for maior que 100', (WidgetTester tester) async {
      await tester.pumpWidget(createFormScreen(notifier: mockNotifier));
      
      await tester.enterText(findNameField(), 'Teste');
      await tester.enterText(findRiskField(), '101'); // Risco Inválido

      await tester.tap(findSaveButton());
      await tester.pump(); 

      expect(find.text('O risco deve ser um número entre 0 e 100'), findsOneWidget);
      verifyNever(mockNotifier.saveStrategy(any));
    });

    // --- Teste 5: Criação Bem-Sucedida ---
    testWidgets('Criação bem-sucedida chama saveStrategy e volta para a lista', (WidgetTester tester) async {
      await tester.pumpWidget(createFormScreen(notifier: mockNotifier));

      await tester.enterText(findNameField(), 'Regra Zero');
      await tester.enterText(findRiskField(), '5'); // 5%

      await tester.tap(findSaveButton());
      await tester.pump(); // Carregamento
      await tester.pumpAndSettle(); // Aguarda o saveStrategy e o pop()

      // Verifica se o saveStrategy foi chamado com o objeto correto
      verify(mockNotifier.saveStrategy(
        argThat(
          isA<BetStrategyModel>()
          .having((s) => s.name, 'name', 'Regra Zero')
          .having((s) => s.riskFactor, 'riskFactor', 0.05) // 5/100
        )
      )).called(1);

      // Verifica o feedback de sucesso
      expect(find.text('Estratégia criada com sucesso!'), findsOneWidget);
      // Verifica se a tela foi fechada (pop)
      expect(find.text('Nova Estratégia'), findsNothing); 
    });
    
    // --- Teste 6: Falha na Persistência ---
    testWidgets('Falha na persistência exibe SnackBar de erro', (WidgetTester tester) async {
      // Simula a falha do Notifier
      when(mockNotifier.saveStrategy(any)).thenThrow(const BetStrategyException('Nome de regra inválido.'));
      
      await tester.pumpWidget(createFormScreen(notifier: mockNotifier));

      await tester.enterText(findNameField(), 'Regra Com Falha');
      await tester.enterText(findRiskField(), '1');

      await tester.tap(findSaveButton());
      await tester.pump(); // Carregamento
      await tester.pumpAndSettle(); // Aguarda a falha e o SnackBar

      // Verifica a mensagem de erro
      expect(find.text('Falha ao salvar: Nome de regra inválido.'), findsOneWidget);
      // A tela NÃO deve ser fechada
      expect(find.text('Nova Estratégia'), findsOneWidget); 
      // Verifica se o botão de salvar não está mais em loading
      expect(findSaveButton(), findsOneWidget);
    });
  });
}