// ignore_for_file: cascade_invocations

import 'package:antibet/features/auth/models/user_model.dart';
import 'package:antibet/features/auth/providers/user_provider.dart';
import 'package:antibet/features/journal/models/journal_model.dart';
import 'package:antibet/features/journal/presentation/journal_screen.dart';
import 'package:antibet/features/journal/providers/journal_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// --- Fakes/Mocks ---

// Fake Notifier para UserProvider
class FakeUserNotifier extends StateNotifier<UserState> {
  FakeUserNotifier(super.initialState);
  void setTestState(UserState newState) => state = newState;
}

// Fake Notifier para JournalProvider
class FakeJournalNotifier extends StateNotifier<JournalState> {
  FakeJournalNotifier(super.initialState);

  int getJournalCallCount = 0;
  String? lastDate;

  Future<void> getJournal(String date) async {
    getJournalCallCount++;
    lastDate = date;
    // Estado controlado pelo teste
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
  const tJournalModel = JournalModel(
    id: '1',
    userId: '1',
    date: '2025-11-17',
    totalBets: 10,
    totalWins: 2,
    totalLost: 8,
    profit: -150.0,
    entries: [],
  );

  setUp(() {
    // 1. Inicializa os fakes
    // Simulamos um usuário já logado, que é o estado normal para esta tela
    fakeUserNotifier = FakeUserNotifier(UserLoaded(user: tUserModel));
    fakeJournalNotifier = FakeJournalNotifier(JournalInitial());

    // 2. Sobrescreve os providers
    container = ProviderContainer(
      overrides: [
        userProvider.overrideWith((ref) => fakeUserNotifier),
        journalProvider.overrideWith((ref) => fakeJournalNotifier),
      ],
    );
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

  testWidgets('JournalScreen deve renderizar o estado inicial (sem journal)',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());

    // Assert
    // Verifica se o DatePicker (CalendarTimeline) está visível
    expect(find.byKey(const ValueKey('journalDatePicker')), findsOneWidget);
    // Verifica a mensagem inicial
    expect(find.text('Selecione uma data para ver o diário.'), findsOneWidget);
  });

  testWidgets('deve exibir CircularProgressIndicator durante o estado JournalLoading',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());

    // Act
    // 3. Força o estado de loading
    fakeJournalNotifier.setTestState(JournalLoading());
    await tester.pump(); // Rebuilda

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Garante que a mensagem inicial sumiu
    expect(find.text('Selecione uma data para ver o diário.'), findsNothing);
  });

  testWidgets('deve exibir SnackBar em caso de JournalError',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());

    // Act
    // 4. Força o estado de erro
    fakeJournalNotifier.setTestState(JournalError(message: 'Falha ao buscar'));
    await tester.pump();

    // Assert
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Falha ao buscar'), findsOneWidget);

    await tester.pumpAndSettle(); // Limpa o SnackBar
  });

  testWidgets('deve exibir os dados do Journal em estado JournalLoaded',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());

    // Act
    // 5. Força o estado de carregado com dados
    fakeJournalNotifier.setTestState(JournalLoaded(journal: tJournalModel));
    await tester.pump(); // Rebuilda

    // Assert
    // Verifica se os widgets que exibem os dados (Stats) apareceram
    expect(find.text('Total de Apostas'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('Lucro/Prejuízo'), findsOneWidget);
    expect(find.text('R\$ -150.00'), findsOneWidget);
  });
}