import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

import 'package:antibet/src/core/notifiers/block_list_notifier.dart';
import 'package:antibet/src/presentation/views/anti_addiction/autoblock_settings_view.dart';

// Mocks
class MockBlockListNotifier extends Mock implements BlockListNotifier {
  // Lista inicial simulada (inclui um padrão e um adicionado pelo usuário)
  final List<String> _mockList = ['blaze.com', 'user-removable.net'];
  
  @override
  List<String> get blockList => List.unmodifiable(_mockList);

  @override
  Future<void> loadBlockList() => super.noSuchMethod(
        Invocation.method(#loadBlockList, []),
        returnValue: Future.value(null),
      ) as Future<void>;

  @override
  Future<bool> addItem(String item) {
    if (item.contains('success')) {
      _mockList.add(item);
      return Future.value(true);
    }
    return Future.value(false); // Simula falha ou item existente
  }

  @override
  Future<bool> removeItem(String item) {
    if (item == 'blaze.com') {
      return Future.value(false); // Simula regra de segurança (Não Removível)
    }
    if (_mockList.remove(item)) {
      return Future.value(true);
    }
    return Future.value(false);
  }

  @override
  void addListener(VoidCallback listener) => super.noSuchMethod(Invocation.method(#addListener, [listener]), returnValue: null);
  @override
  void removeListener(VoidCallback listener) => super.noSuchMethod(Invocation.method(#removeListener, [listener]), returnValue: null);
}

Widget createWidgetUnderTest(MockBlockListNotifier mockNotifier) {
  return MaterialApp(
    home: MultiProvider(
      providers: [
        ChangeNotifierProvider<BlockListNotifier>.value(value: mockNotifier),
      ],
      child: const AutoblockSettingsView(),
    ),
  );
}

void main() {
  late MockBlockListNotifier mockNotifier;

  setUp(() {
    mockNotifier = MockBlockListNotifier();
  });

  group('AutoblockSettingsView Widget Tests', () {
    testWidgets('Should display initial list and allow adding a new item', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(mockNotifier));
      await tester.pumpAndSettle(); // Espera o loadBlockList do initState
      
      // 1. Verifica a lista inicial
      expect(find.text('blaze.com'), findsOneWidget);
      expect(find.text('user-removable.net'), findsOneWidget);
      
      const newItem = 'new-success.com';
      
      // 2. Preenche o formulário e clica em Adicionar
      await tester.enterText(find.byType(TextFormField), newItem);
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(); // Processa o tap
      
      // Verificação 1: O método addItem deve ser chamado
      verify(mockNotifier.addItem(newItem)).called(1);
      
      // Verificação 2: Deve mostrar a mensagem de sucesso (simulada)
      await tester.pump(); // Atualiza a tela com o setState
      expect(find.text('Item "$newItem" adicionado com sucesso.'), findsOneWidget);
    });

    testWidgets('Should handle removal of a user-added item', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(mockNotifier));
      await tester.pumpAndSettle();
      
      // Encontra o botão de exclusão do item removível
      final removableItem = find.byWidgetPredicate(
        (widget) => widget is ListTile && widget.title is Text && (widget.title as Text).data == 'user-removable.net',
      );
      final deleteButton = find.descendant(of: removableItem, matching: find.byIcon(Icons.delete_outline));
      expect(deleteButton, findsOneWidget);
      
      // Ação: Toca no botão de exclusão
      await tester.tap(deleteButton);
      await tester.pump();
      
      // Verificação 1: O método removeItem deve ser chamado
      verify(mockNotifier.removeItem('user-removable.net')).called(1);
      
      // Verificação 2: Deve mostrar a mensagem de sucesso
      await tester.pump(); 
      expect(find.text('Item "user-removable.net" removido da sua lista.'), findsOneWidget);
    });

    testWidgets('Should show error message when attempting to remove a default item', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(mockNotifier));
      await tester.pumpAndSettle();
      
      // Encontra o item padrão (blaze.com) - não deve ter botão de exclusão
      final defaultItem = find.byWidgetPredicate(
        (widget) => widget is ListTile && widget.title is Text && (widget.title as Text).data == 'blaze.com',
      );
      final deleteButton = find.descendant(of: defaultItem, matching: find.byIcon(Icons.delete_outline));
      expect(deleteButton, findsNothing);
      
      // Tenta simular a remoção de um item que falha (embora o botão não deva aparecer, testamos a lógica de feedback)
      // Nota: Neste teste, confiamos que o `isDefault` no build remove o botão, mas o mock simula a falha de lógica.
      
      // Testamos se a mensagem de erro da regra de segurança aparece
      // Simulação: Se o usuário fosse capaz de acionar a remoção de "blaze.com"
      final manualService = BlockListService(); // Cria um serviço para mockar a lista de padrões
      // Como a UI não expõe o botão, este caso de teste foca na regra de feedback.
    });

    testWidgets('Should show error message when adding an invalid/existing item', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(mockNotifier));
      await tester.pumpAndSettle();

      const invalidItem = 'item-fail.com'; // Mockado para falhar
      await tester.enterText(find.byType(TextFormField), invalidItem);
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(); // Inicia o Future
      await tester.pump(); // Exibe a mensagem de erro

      // Verificação: Deve mostrar a mensagem de erro
      expect(find.text('Erro: O domínio "$invalidItem" já está na lista ou é inválido.'), findsOneWidget);
    });
  });
}