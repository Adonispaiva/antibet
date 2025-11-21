import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:antibet/features/journal/data/models/journal_entry_model.dart';
import 'package:antibet/features/journal/data/models/journal_model.dart';
import 'package:antibet/features/journal/presentation/providers/journal_provider.dart';
import 'package:antibet/features/journal/presentation/screens/edit_entry_screen.dart';

// Mocks
class MockJournalNotifier extends StateNotifier<AsyncValue<JournalModel>> with Mock implements JournalNotifier {
  MockJournalNotifier() : super(const AsyncValue.data(JournalModel(
        entries: [],
        totalInvested: 0,
        totalWins: 0,
        totalLosses: 0,
      )));

  @override
  Future<bool> updateEntry(JournalEntryModel entry) async => true;

  @override
  Future<bool> deleteEntry(String id) async => true;

  @override
  // Mockamos o getJournal para evitar chamadas reais durante o teste
  Future<void> getJournal() async {} 
}

// Wrapper para simular o ProviderScope e o contexto de navegação
class TestEditWrapper extends StatelessWidget {
  final Widget child;
  final MockJournalNotifier mockNotifier;

  const TestEditWrapper({super.key, required this.child, required this.mockNotifier});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        journalProvider.overrideWithValue(mockNotifier),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) {
            // Usa um GoRouter simples para simular a navegação (pop/go)
            return GoRouter(
              routes: [
                GoRoute(path: '/', builder: (c, s) => child),
                GoRoute(path: '/journal', builder: (c, s) => const Text('Journal List')),
              ],
              initialLocation: '/',
            );
          },
        ),
      ),
    );
  }
}

void main() {
  late MockJournalNotifier mockNotifier;

  setUp(() {
    mockNotifier = MockJournalNotifier();
    // Registra o fallback para JournalEntryModel
    registerFallbackValue(const JournalEntryModel(
      id: 'any',
      description: 'any',
      amount: 0.0,
      isWin: false,
      date: 'any',
    ));
  });

  group('EditEntryScreen Widget Test', () {
    final tEntry = JournalEntryModel(
      id: 'e1',
      description: 'Initial Bet',
      amount: 50.0,
      isWin: false,
      date: DateTime.now(),
    );

    testWidgets('should update entry successfully on save button tap', (WidgetTester tester) async {
      // Arrange
      when(() => mockNotifier.updateEntry(any())).thenAnswer((_) async => true);
      
      await tester.pumpWidget(TestEditWrapper(
        child: EditEntryScreen(entry: tEntry),
        mockNotifier: mockNotifier,
      ));
      await tester.pumpAndSettle();

      const newDescription = 'Updated Description';

      // Act
      // 1. Edita o campo de descrição
      await tester.enterText(find.byKey(const Key('description_field')), newDescription);
      
      // 2. Toca no botão de salvar
      await tester.tap(find.byKey(const Key('save_edit_button')));
      await tester.pumpAndSettle(const Duration(seconds: 1)); // Simula o tempo de API/navegação

      // Assert
      // Verifica se o método de update foi chamado no provider (com a nova descrição)
      verify(() => mockNotifier.updateEntry(
        any(
          that: isA<JournalEntryModel>().having((e) => e.description, 'description', newDescription),
        ),
      )).called(1);
      
      // Verifica a navegação para a tela do diário
      expect(find.text('Journal List'), findsOneWidget);
    });

    testWidgets('should delete entry successfully after confirmation', (WidgetTester tester) async {
      // Arrange
      when(() => mockNotifier.deleteEntry(tEntry.id)).thenAnswer((_) async => true);
      
      await tester.pumpWidget(TestEditWrapper(
        child: EditEntryScreen(entry: tEntry),
        mockNotifier: mockNotifier,
      ));
      await tester.pumpAndSettle();

      // Act
      // 1. Toca no botão de deletar
      await tester.tap(find.byKey(const Key('delete_entry_button')));
      await tester.pumpAndSettle(); // Mostra o AlertDialog
      
      // 2. Toca no botão de confirmação
      expect(find.text('CONFIRMAR'), findsOneWidget);
      await tester.tap(find.byKey(const Key('confirm_delete_button')));
      await tester.pumpAndSettle(const Duration(seconds: 1)); // Simula o tempo de API/navegação

      // Assert
      // Verifica se o método de delete foi chamado no provider
      verify(() => mockNotifier.deleteEntry(tEntry.id)).called(1);
      
      // Verifica a navegação para a tela do diário
      expect(find.text('Journal List'), findsOneWidget);
    });

    testWidgets('should not delete entry if confirmation is cancelled', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(TestEditWrapper(
        child: EditEntryScreen(entry: tEntry),
        mockNotifier: mockNotifier,
      ));
      await tester.pumpAndSettle();

      // Act
      // 1. Toca no botão de deletar
      await tester.tap(find.byKey(const Key('delete_entry_button')));
      await tester.pumpAndSettle(); // Mostra o AlertDialog
      
      // 2. Toca no botão de CANCELAR
      expect(find.text('CANCELAR'), findsOneWidget);
      await tester.tap(find.text('CANCELAR'));
      await tester.pumpAndSettle(); 

      // Assert
      // Verifica se o método de delete NUNCA foi chamado
      verifyNever(() => mockNotifier.deleteEntry(any()));
      
      // Garante que permaneceu na tela de edição
      expect(find.byType(EditEntryScreen), findsOneWidget);
    });
  });
}