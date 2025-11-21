// ignore_for_file: cascade_invocations

import 'package:antibet/features/journal/models/journal_entry_model.dart';
import 'package:antibet/features/journal/presentation/add_entry_screen.dart';
import 'package:antibet/features/journal/providers/journal_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Fake Notifier para JournalProvider
class FakeJournalNotifier extends StateNotifier<JournalState> {
  FakeJournalNotifier(JournalState initialState) : super(initialState);

  int createEntryCallCount = 0;
  JournalEntryModel? lastEntryCreated;

  // Simula o método createEntry
  @override
  Future<void> createEntry(JournalEntryModel entry) async {
    createEntryCallCount++;
    lastEntryCreated = entry;
    // Simula sucesso imediato
    state = JournalLoaded(
        journal:
            state.journalOrNull ?? JournalModel.empty('2025-11-17', userId: '1'));
  }

  // Simula o método getJournal (necessário para o pop-up de sucesso)
  @override
  Future<void> getJournal(String date) async {}

  void setTestState(JournalState newState) => state = newState;
}

void main() {
  late ProviderContainer container;
  late FakeJournalNotifier fakeJournalNotifier;

  setUp(() {
    // 1. Inicializa o FakeNotifier no estado inicial
    fakeJournalNotifier = FakeJournalNotifier(JournalInitial());

    // 2. Sobrescreve o provider
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
      child: const MaterialApp(
        home: AddEntryScreen(),
      ),
    );
  }

  testWidgets('AddEntryScreen deve renderizar todos os campos obrigatórios',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());

    // Assert
    expect(find.text('Nova Aposta'), findsOneWidget);
    expect(find.text('Descrição (Ex: Futebol - Vitória Time A)'), findsOneWidget);
    expect(find.text('Plataforma (Ex: Bet365)'), findsOneWidget);
    expect(find.text('Investimento (R\$)'), findsOneWidget);
    expect(find.text('ODDS (Ex: 1.85)'), findsOneWidget);
    expect(find.text('Valor de Retorno (R\$)'), findsOneWidget);
    expect(find.text('Registrar Aposta'), findsOneWidget);
  });

  testWidgets(
      'deve chamar provider.createEntry() com dados corretos ao submeter o formulário',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());

    // 1. Preenche os campos
    await tester.enterText(
        find.widgetWithText(CustomTextField, 'Descrição (Ex: Futebol - Vitória Time A)'), 'Vitoria Certa');
    await tester.enterText(
        find.widgetWithText(CustomTextField, 'Plataforma (Ex: Bet365)'), 'Betfair');
    await tester.enterText(
        find.widgetWithText(CustomTextField, 'Investimento (R\$)'), '150.0');
    await tester.enterText(
        find.widgetWithText(CustomTextField, 'ODDS (Ex: 1.85)'), '2.10');
    await tester.enterText(
        find.widgetWithText(CustomTextField, 'Valor de Retorno (R\$)'), '315.0');
    
    // 2. Seleciona o resultado (Dropdown)
    await tester.tap(find.text('Selecione o resultado'));
    await tester.pumpAndSettle(); // Abre o dropdown
    await tester.tap(find.text('Ganho Total').last);
    await tester.pumpAndSettle(); // Fecha o dropdown

    // 3. Tapa no botão
    await tester.tap(find.text('Registrar Aposta'));
    
    // 4. Espera o processamento (simulado) e o pop da tela
    await tester.pumpAndSettle(); 

    // Assert
    // Verifica se a função de criação foi chamada
    expect(fakeJournalNotifier.createEntryCallCount, 1);
    // Verifica se os dados do modelo criado estão corretos
    expect(fakeJournalNotifier.lastEntryCreated!.description, 'Vitoria Certa');
    expect(fakeJournalNotifier.lastEntryCreated!.investment, 150.0);
    expect(fakeJournalNotifier.lastEntryCreated!.odds, 2.10);
    expect(fakeJournalNotifier.lastEntryCreated!.returnAmount, 315.0);
    expect(fakeJournalNotifier.lastEntryCreated!.result, BetResult.win);
  });
  
  testWidgets('deve exibir CircularProgressIndicator durante o estado JournalLoading',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());
    
    // Simula o preenchimento para acionar a submissão
    await tester.enterText(find.widgetWithText(CustomTextField, 'Descrição (Ex: Futebol - Vitória Time A)'), 'Teste');
    await tester.enterText(find.widgetWithText(CustomTextField, 'Investimento (R\$)'), '10.0');
    await tester.enterText(find.widgetWithText(CustomTextField, 'ODDS (Ex: 1.85)'), '1.5');
    await tester.enterText(find.widgetWithText(CustomTextField, 'Valor de Retorno (R\$)'), '15.0');
    await tester.tap(find.text('Selecione o resultado'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pendente').last);
    await tester.pumpAndSettle();

    // Act 1: Tapa no botão (estado deve ir para Loading)
    tester.tap(find.text('Registrar Aposta'));
    
    // Act 2: Força o estado de Loading
    fakeJournalNotifier.setTestState(JournalLoading());
    await tester.pump();

    // Assert
    // O botão deve ser substituído pelo indicador
    final buttonFinder = find.widgetWithText(CustomButton, 'Registrar Aposta');
    final buttonWidget = tester.widget<CustomButton>(buttonFinder);
    expect(buttonWidget.isLoading, isTrue);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}