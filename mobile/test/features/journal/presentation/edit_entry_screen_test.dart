// ignore_for_file: cascade_invocations

import 'package:antibet/features/journal/models/journal_entry_model.dart';
import 'package:antibet/features/journal/presentation/edit_entry_screen.dart';
import 'package:antibet/features/journal/providers/journal_provider.dart';
import 'package:antibet/utils/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Fake Notifier para JournalProvider (Reutilizando a estrutura do AddEntryScreenTest)
class FakeJournalNotifier extends StateNotifier<JournalState> {
  FakeJournalNotifier(JournalState initialState) : super(initialState);

  int updateEntryCallCount = 0;
  int deleteEntryCallCount = 0;
  JournalEntryModel? lastEntryUpdated;
  String? lastEntryIdDeleted;

  @override
  Future<void> updateEntry(JournalEntryModel entry) async {
    updateEntryCallCount++;
    lastEntryUpdated = entry;
    // Simula sucesso imediato
    state = JournalLoaded(
        journal:
            state.journalOrNull ?? JournalModel.empty('2025-11-17', userId: '1'));
  }
  
  @override
  Future<void> deleteEntry(String entryId) async {
    deleteEntryCallCount++;
    lastEntryIdDeleted = entryId;
    // Simula sucesso imediato
    state = JournalLoaded(
        journal:
            state.journalOrNull ?? JournalModel.empty('2025-11-17', userId: '1'));
  }

  @override
  Future<void> getJournal(String date) async {}

  void setTestState(JournalState newState) => state = newState;
}

void main() {
  late ProviderContainer container;
  late FakeJournalNotifier fakeJournalNotifier;

  // Modelo de teste de entrada existente
  final tExistingEntry = JournalEntryModel(
    id: 'e1',
    journalId: 'j1',
    investment: 100.0,
    odds: 2.0,
    returnAmount: 200.0,
    result: BetResult.pending,
    platform: 'Betfair',
    description: 'Aposta Antiga',
    createdAt: DateTime.now(),
  );

  setUp(() {
    fakeJournalNotifier = FakeJournalNotifier(JournalInitial());

    container = ProviderContainer(
      overrides: [
        journalProvider.overrideWith((ref) => fakeJournalNotifier),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  // Função helper para inflar o widget
  Widget createWidgetUnderTest() {
    return ProviderScope(
      parent: container,
      child: MaterialApp(
        home: EditEntryScreen(entry: tExistingEntry),
      ),
    );
  }

  testWidgets('EditEntryScreen deve pré-preencher campos com dados da entrada',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Assert
    // Verifica a pré-população dos campos
    expect(find.text('Aposta Antiga'), findsOneWidget); // Descrição
    expect(find.text('Betfair'), findsOneWidget); // Plataforma
    expect(find.text('Pendente'), findsOneWidget); // Resultado (Dropdown)
    expect(find.text('100.0'), findsOneWidget); // Investimento
    expect(find.text('200.0'), findsOneWidget); // Retorno
  });

  group('Ações de Submissão e Atualização', () {
    testWidgets('deve chamar provider.updateEntry() com os dados modificados',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // 1. Modifica o campo de Retorno
      await tester.enterText(
          find.widgetWithText(CustomTextField, 'Valor de Retorno (R\$)'), '220.0');
      
      // 2. Modifica o resultado para GANHO TOTAL
      await tester.tap(find.text('Pendente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ganho Total').last);
      await tester.pumpAndSettle();

      // 3. Tapa no botão de Salvar
      await tester.tap(find.byKey(const ValueKey('saveEntryButton')));
      await tester.pumpAndSettle();

      // Assert
      // Verifica se a função de atualização foi chamada
      expect(fakeJournalNotifier.updateEntryCallCount, 1);
      // Verifica se o modelo enviado está correto (com o novo Retorno e Resultado)
      expect(fakeJournalNotifier.lastEntryUpdated!.returnAmount, 220.0);
      expect(fakeJournalNotifier.lastEntryUpdated!.result, BetResult.win);
      // Verifica se o ID original foi mantido
      expect(fakeJournalNotifier.lastEntryUpdated!.id, 'e1');
    });

    testWidgets('deve exibir CircularProgressIndicator durante o estado JournalLoading',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act 1: Tapa no botão (simulando que o provider foi para o estado Loading)
      tester.tap(find.byKey(const ValueKey('saveEntryButton')));
      fakeJournalNotifier.setTestState(JournalLoading());
      await tester.pump();

      // Assert
      final buttonFinder = find.widgetWithText(CustomButton, 'Salvar Alterações');
      final buttonWidget = tester.widget<CustomButton>(buttonFinder);
      expect(buttonWidget.isLoading, isTrue);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('Ações de Exclusão (Delete)', () {
    testWidgets('deve exibir AlertDialog ao tocar no botão Deletar',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.byKey(const ValueKey('deleteEntryButton')));
      await tester.pump(); // Abre o diálogo

      // Assert
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Confirmar Exclusão'), findsOneWidget);
      expect(find.text('Deletar'), findsOneWidget);
    });

    testWidgets('deve chamar provider.deleteEntry() e navegar ao confirmar a exclusão',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act 1: Tapa em Deletar para abrir o diálogo
      await tester.tap(find.byKey(const ValueKey('deleteEntryButton')));
      await tester.pump(); 

      // Act 2: Tapa no botão 'Deletar' dentro do diálogo
      await tester.tap(find.widgetWithText(TextButton, 'Deletar'));
      await tester.pumpAndSettle(); // Aguarda a chamada da função e o pop

      // Assert
      // 1. Verifica se a função de exclusão foi chamada com o ID correto
      expect(fakeJournalNotifier.deleteEntryCallCount, 1);
      expect(fakeJournalNotifier.lastEntryIdDeleted, 'e1');
      // 2. Verifica se houve navegação de volta (pop)
      expect(find.byType(EditEntryScreen), findsNothing);
    });

    testWidgets('não deve chamar provider.deleteEntry() ao cancelar a exclusão',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act 1: Tapa em Deletar para abrir o diálogo
      await tester.tap(find.byKey(const ValueKey('deleteEntryButton')));
      await tester.pump(); 

      // Act 2: Tapa no botão 'Cancelar' dentro do diálogo
      await tester.tap(find.widgetWithText(TextButton, 'Cancelar'));
      await tester.pumpAndSettle(); // Fecha o diálogo

      // Assert
      // 1. Verifica que a função de exclusão NÃO foi chamada
      expect(fakeJournalNotifier.deleteEntryCallCount, 0);
      // 2. Verifica que a tela de edição continua visível
      expect(find.byType(EditEntryScreen), findsOneWidget);
    });
  });
}