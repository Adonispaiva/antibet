import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:antibet/features/journal/data/models/journal_model.dart';
import 'package:antibet/features/journal/presentation/providers/journal_provider.dart';
import 'package:antibet/features/journal/presentation/screens/add_entry_screen.dart';

// Mocks
class MockJournalNotifier extends StateNotifier<AsyncValue<JournalModel>> with Mock implements JournalNotifier {
  MockJournalNotifier() : super(const AsyncValue.data(JournalModel(
        entries: [],
        totalInvested: 0,
        totalWins: 0,
        totalLosses: 0,
      )));

  @override
  // Método de criação é o foco deste teste
  Future<bool> createEntry(String description, double amount, bool isWin) async => true;
  
  @override
  // Mockamos o getJournal para evitar chamadas reais durante o teste
  Future<void> getJournal() async {} 
}

// Wrapper para simular o ProviderScope e o contexto de navegação
class TestAddWrapper extends StatelessWidget {
  final Widget child;
  final MockJournalNotifier mockNotifier;

  const TestAddWrapper({super.key, required this.child, required this.mockNotifier});

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
    // Registra o fallback para os parâmetros de createEntry
    registerFallbackValue('any description');
    registerFallbackValue(0.0);
    registerFallbackValue(false);
  });

  group('AddEntryScreen Widget Test', () {
    const tDescription = 'New Test Bet';
    const tAmount = 75.50;

    testWidgets('should show error when submitting invalid data', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(TestAddWrapper(
        mockNotifier: mockNotifier,
        child: const AddEntryScreen(),
      ));
      await tester.pumpAndSettle();

      // Act: Tenta submeter com campos vazios
      await tester.tap(find.byKey(const Key('save_entry_button')));
      await tester.pump(); // Aciona a validação

      // Assert
      expect(find.text('A descrição não pode ser vazia.'), findsOneWidget);
      expect(find.text('Insira um valor numérico válido.'), findsOneWidget);
      verifyNever(() => mockNotifier.createEntry(any(), any(), any()));
    });

    testWidgets('should call createEntry and navigate on success', (WidgetTester tester) async {
      // Arrange
      when(() => mockNotifier.createEntry(tDescription, tAmount, true)).thenAnswer((_) async => true);

      await tester.pumpWidget(TestAddWrapper(
        mockNotifier: mockNotifier,
        child: const AddEntryScreen(),
      ));
      await tester.pumpAndSettle();

      // Act: Preenche os campos
      await tester.enterText(find.byKey(const Key('description_field')), tDescription);
      await tester.enterText(find.byKey(const Key('amount_field')), tAmount.toString());
      await tester.tap(find.byKey(const Key('is_win_switch'))); // Muda para 'Ganhou' (true)
      await tester.pumpAndSettle();

      // Act: Toca no botão de salvar
      await tester.tap(find.byKey(const Key('save_entry_button')));
      await tester.pump(); // Loading state
      
      await tester.pumpAndSettle(const Duration(seconds: 1)); // Simula o tempo de API/navegação

      // Assert
      // Verifica se o método de criação foi chamado no provider
      verify(() => mockNotifier.createEntry(tDescription, tAmount, true)).called(1);
      
      // Verifica a navegação para a tela do diário
      expect(find.text('Journal List'), findsOneWidget);
      
      // Verifica o SnackBar de sucesso
      expect(find.text('Nova entrada registrada com sucesso!'), findsOneWidget);
    });

    testWidgets('should show error SnackBar on createEntry failure', (WidgetTester tester) async {
      // Arrange
      when(() => mockNotifier.createEntry(any(), any(), any())).thenAnswer((_) async => false);

      await tester.pumpWidget(TestAddWrapper(
        mockNotifier: mockNotifier,
        child: const AddEntryScreen(),
      ));
      await tester.pumpAndSettle();

      // Act: Preenche os campos e tenta salvar
      await tester.enterText(find.byKey(const Key('description_field')), tDescription);
      await tester.enterText(find.byKey(const Key('amount_field')), tAmount.toString());
      await tester.tap(find.byKey(const Key('save_entry_button')));
      await tester.pump(); 
      await tester.pump(const Duration(milliseconds: 500)); // Simula o SnackBar aparecer

      // Assert
      // Verifica a mensagem de erro do SnackBar
      expect(find.text('Falha ao registrar a entrada.'), findsOneWidget);
      
      // Garante que permaneceu na tela de adição
      expect(find.byType(AddEntryScreen), findsOneWidget);
    });
  });
}