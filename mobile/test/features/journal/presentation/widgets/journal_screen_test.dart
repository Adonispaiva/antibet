// ignore_for_file: cascade_invocations

import 'package:antibet/features/auth/models/user_model.dart';
import 'package:antibet/features/auth/providers/user_provider.dart';
import 'package:antibet/features/journal/models/journal_entry_model.dart';
import 'package:antibet/features/journal/models/journal_model.dart';
import 'package:antibet/features/journal/presentation/journal_screen.dart';
import 'package:antibet/features/journal/providers/journal_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// --- Fakes/Mocks ---

// Fake Notifier para UserProvider (necessário para o AppBar)
class FakeUserNotifier extends StateNotifier<UserState> {
  FakeUserNotifier(super.initialState);
  void setTestState(UserState newState) => state = newState;
  
  // Simula o logout para verificação de chamadas
  int logoutCallCount = 0;
  Future<void> logout() async {
    logoutCallCount++;
    state = UserLoading();
    // O HomeScreen fará a navegação após o UserLoggedOut
  }
}

// Fake Notifier para JournalProvider
class FakeJournalNotifier extends StateNotifier<JournalState> {
  FakeJournalNotifier(super.initialState);

  int getJournalCallCount = 0;
  String? lastDate;

  Future<void> getJournal(String date) async {
    getJournalCallCount++;
    lastDate = date;
    // O estado será controlado manualmente pelo teste
  }

  void setTestState(JournalState newState) => state = newState;
}

void main() {
  late ProviderContainer container;
  late FakeUserNotifier fakeUserNotifier;
  late FakeJournalNotifier fakeJournalNotifier;

  // Modelos de Teste
  final tUserModel = UserModel(
      id: '1', name: 'Test User', email: 'test@example.com', token: 'token');
  final tEntryModel = JournalEntryModel(
      id: 'e1', journalId: 'j1', investment: 10.0, odds: 2.0, returnAmount: 20.0, result: BetResult.win, platform: 'X', description: 'Aposta Teste', createdAt: DateTime.now());
  final tJournalModel = JournalModel(
    id: '1',
    userId: '1',
    date: '2025-11-17',
    totalBets: 1,
    totalWins: 1,
    totalLost: 0,
    profit: 10.0,
    entries: [tEntryModel],
  );

  setUp(() {
    // 1. Inicializa os fakes
    fakeUserNotifier = FakeUserNotifier(UserLoaded(user: tUserModel));
    fakeJournalNotifier = FakeJournalNotifier(JournalInitial());

    // 2. Sobrescreve os providers
    container = ProviderContainer(
      overrides: [
        // O userProvider deve ser overrideWith o Notifier para que o logout seja chamado
        userProvider.overrideWith((ref) => fakeUserNotifier), 
        journalProvider.overrideWith((ref) => fakeJournalNotifier),
      ],
    );
    
    // Assegura que o JournalInitial é o estado antes do pump
    fakeJournalNotifier.setTestState(JournalInitial());
  });

  tearDown(() {
    container.dispose();
  });

  // Função helper
  Widget createWidgetUnderTest() {
    return ProviderScope(
      parent: container,
      child: const MaterialApp(
        home: JournalScreen(),
      ),
    );
  }

  testWidgets('JournalScreen deve chamar getJournal() ao iniciar (data de hoje)',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());
    
    // Aguarda o callback do initState (addPostFrameCallback)
    await tester.pumpAndSettle(); 

    // Assert
    // Verifica se a busca pelo diário foi chamada
    expect(fakeJournalNotifier.getJournalCallCount, 1);
    // Verifica se a data é a de hoje (o formato yyyy-MM-dd)
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    expect(fakeJournalNotifier.lastDate, todayString);
  });
  
  testWidgets('JournalScreen deve exibir o nome do usuário no AppBar',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle(); 

    // Assert
    expect(find.text('Olá, Test User'), findsOneWidget);
  });

  testWidgets('Tocar no botão de Logout deve chamar userProvider.logout()',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Act
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pump(); 

    // Assert
    expect(fakeUserNotifier.logoutCallCount, 1);
  });

  testWidgets('deve exibir CircularProgressIndicator durante o estado JournalLoading',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());

    // Act
    fakeJournalNotifier.setTestState(JournalLoading());
    await tester.pump();

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Garante que a mensagem inicial sumiu
    expect(find.text('Selecione uma data para ver o diário.'), findsNothing);
  });

  testWidgets('deve exibir SnackBar em caso de JournalError',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Act
    fakeJournalNotifier.setTestState(JournalError(message: 'Falha ao buscar'));
    await tester.pump();

    // Assert
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Falha ao buscar'), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('deve exibir os dados do Journal em estado JournalLoaded',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Act
    fakeJournalNotifier.setTestState(JournalLoaded(journal: tJournalModel));
    await tester.pump(); 

    // Assert
    // Verifica se o widget de stats apareceu (contém o título 'Total de Apostas')
    expect(find.text('Total de Apostas'), findsOneWidget); 
    // Verifica se a entrada do diário (JournalEntryItem) apareceu
    expect(find.text('Aposta Teste'), findsOneWidget);
  });
}