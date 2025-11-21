import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:antibet/features/journal/services/journal_service.dart';
import 'package:antibet/features/journal/models/journal_entry_model.dart';
import 'package:antibet/features/journal/providers/journal_provider.dart';
import 'package:antibet/features/journal/screens/journal_screen.dart';
import 'package:antibet/features/journal/screens/add_entry_screen.dart';
import 'package:antibet/features/journal/screens/edit_entry_screen.dart';

// Mock (Deve estender Mock para funcionar com mockito)
class MockJournalService extends Mock implements JournalService {}

void main() {
  late MockJournalService mockJournalService;

  // Lista para simular o banco de dados e controlar o estado no Mock
  List<JournalEntryModel> mockEntries = [];

  // Dados de teste
  final entryId1 = 'entry_test_1';
  final initialAmount = 100.00;
  final initialDesc = 'Aposta Inicial para Teste';
  final editedAmount = 150.00;
  final editedDesc = 'Aposta Editada com Sucesso';

  // Configuração antes de cada teste
  setUp(() {
    mockJournalService = MockJournalService();
    mockEntries.clear();
    
    // Configura o Mock para o GET (Leitura)
    when(mockJournalService.getEntries()).thenAnswer((_) async => mockEntries);
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        // Sobrescreve o provider do serviço para usar o Mock e isolar a API real
        journalServiceProvider.overrideWithValue(mockJournalService),
      ],
      child: const MaterialApp(
        home: JournalScreen(),
      ),
    );
  }

  group('Journal CRUD Integration Flow', () {
    testWidgets('Deve completar o ciclo de Criar, Editar e Deletar uma aposta no fluxo do usuário', (WidgetTester tester) async {
      // 1. Iniciar App na tela de Journal
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verificação Inicial: Lista vazia
      expect(find.text('Nenhuma aposta registrada. Use o "+" para começar.'), findsOneWidget);

      // --- PASSO 2: CRIAR ENTRADA ---
      
      // Configura o Mock para o CREATE
      when(mockJournalService.createEntry(any)).thenAnswer((Invocation inv) async {
        final data = inv.positionalArguments[0] as Map<String, dynamic>;
        final newEntry = JournalEntryModel(
          id: entryId1,
          amount: data['amount'] as double,
          description: data['description'] as String,
          date: DateTime.now(),
          type: 'bet',
        );
        mockEntries.add(newEntry);
        return newEntry;
      });

      // Acessar tela de adição
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(); 
      expect(find.byType(AddEntryScreen), findsOneWidget);

      // Preencher formulário
      await tester.enterText(find.byKey(const Key('amount_field')), initialAmount.toString());
      await tester.enterText(find.byKey(const Key('description_field')), initialDesc);
      
      // Submeter
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500)); // Espera o processamento do Provider

      // Verificar Sucesso e Retorno (LISTA)
      expect(find.byType(JournalScreen), findsOneWidget);
      expect(find.text('Aposta registrada com sucesso!'), findsOneWidget); // Feedback Manager
      expect(find.text(initialDesc), findsOneWidget); 
      expect(find.text('R\$ ${initialAmount.toStringAsFixed(2)}'), findsOneWidget);

      // --- PASSO 3: EDITAR ENTRADA ---
      
      // Configura o Mock para o UPDATE
      when(mockJournalService.updateEntry(any, any)).thenAnswer((Invocation inv) async {
        final data = inv.positionalArguments[1] as Map<String, dynamic>;
        final updatedEntry = mockEntries[0].copyWith(
          amount: data['amount'],
          description: data['description'],
        );
        mockEntries[0] = updatedEntry; // Atualiza a lista mockada
        return updatedEntry;
      });
      
      // Clicar no item recém criado (abre EditEntryScreen)
      await tester.tap(find.text(initialDesc));
      await tester.pumpAndSettle(); 
      expect(find.byType(EditEntryScreen), findsOneWidget);

      // Alterar valor
      await tester.enterText(find.byKey(const Key('amount_field')), editedAmount.toString());
      await tester.enterText(find.byKey(const Key('description_field')), editedDesc);
      
      // Salvar alteração
      await tester.tap(find.text('Salvar Alterações'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Verificar atualização na lista
      expect(find.byType(JournalScreen), findsOneWidget);
      expect(find.text('Aposta #$entryId1 atualizada com sucesso!'), findsOneWidget); // Feedback Manager
      expect(find.text(editedDesc), findsOneWidget);
      expect(find.text('R\$ ${editedAmount.toStringAsFixed(2)}'), findsOneWidget);

      // --- PASSO 4: DELETAR ENTRADA ---
      
      // Configura o Mock para o DELETE
      when(mockJournalService.deleteEntry(any)).thenAnswer((_) async {
        mockEntries.removeWhere((e) => e.id == entryId1);
      });
      
      // Clicar novamente no item
      await tester.tap(find.text(editedDesc));
      await tester.pumpAndSettle();

      // Clicar no botão de deletar (canto superior direito)
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Verificar Dialog de confirmação
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Confirmar')); 
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Verificar se voltou para lista e se está vazia
      expect(find.byType(JournalScreen), findsOneWidget);
      expect(find.text('Aposta excluída com sucesso.'), findsOneWidget); // Feedback Manager
      expect(find.text(editedDesc), findsNothing);
      expect(find.text('Nenhuma aposta registrada. Use o "+" para começar.'), findsOneWidget);
    });
  });
}