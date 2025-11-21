import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:antibet/main.dart';
import 'package:antibet/features/auth/presentation/screens/login_screen.dart';
import 'package:antibet/features/journal/presentation/screens/journal_screen.dart';
import 'package:antibet/features/journal/presentation/screens/add_entry_screen.dart';
import 'package:antibet/features/journal/presentation/screens/edit_entry_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E CRUD Journal Flow Test', () {
    // Dados de teste
    const String testEmail = 'test_integration@inovexa.com';
    const String testPassword = 'Password123!';
    const String newDescription = 'Aposta de Integração E2E';
    const String updatedDescription = 'Aposta Atualizada E2E';
    const double betAmount = 50.0;

    Future<void> loginTestUser(WidgetTester tester) async {
      // 1. Aguarda o app carregar
      await tester.pumpAndSettle();
      
      // Verifica se estamos na tela de login
      expect(find.byType(LoginScreen), findsOneWidget);

      // 2. Inserir credenciais
      await tester.enterText(find.byKey(const Key('email_field')), testEmail);
      await tester.enterText(find.byKey(const Key('password_field')), testPassword);
      await tester.pumpAndSettle();

      // 3. Tocar no botão de login
      await tester.tap(find.byKey(const Key('login_button')));
      
      // Aguarda a navegação e processamento da API
      await tester.pumpAndSettle(const Duration(seconds: 4)); 

      // 4. Verificar se a navegação para a JournalScreen ocorreu
      expect(find.byType(JournalScreen), findsOneWidget);
    }

    testWidgets('Full CRUD Cycle for Journal Entry', (WidgetTester tester) async {
      // Inicia o aplicativo
      await tester.pumpWidget(const MyApp());
      
      // === 1. LOGIN ===
      await loginTestUser(tester);

      // === 2. CREATE (Criação) ===
      
      // 2.1. Navegar para a tela de Adicionar Entrada via FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(AddEntryScreen), findsOneWidget);

      // 2.2. Preencher formulário
      await tester.enterText(find.byKey(const Key('description_field')), newDescription);
      await tester.enterText(find.byKey(const Key('amount_field')), betAmount.toString());
      
      // 2.3. Salvar a entrada
      await tester.tap(find.byKey(const Key('save_entry_button')));
      await tester.pumpAndSettle(const Duration(seconds: 4)); // Esperar a API
      
      // 2.4. Verificar se voltou para JournalScreen e a entrada está lá
      expect(find.byType(JournalScreen), findsOneWidget);
      expect(find.text(newDescription), findsOneWidget);
      
      // === 3. UPDATE (Atualização) ===
      
      // 3.1. Tocar na entrada recém-criada
      await tester.tap(find.text(newDescription));
      await tester.pumpAndSettle();
      expect(find.byType(EditEntryScreen), findsOneWidget);
      
      // 3.2. Atualizar a descrição
      await tester.enterText(find.byKey(const Key('description_field')), updatedDescription);
      
      // 3.3. Salvar a atualização
      await tester.tap(find.byKey(const Key('save_edit_button')));
      await tester.pumpAndSettle(const Duration(seconds: 4)); // Esperar a API
      
      // 3.4. Verificar se voltou para JournalScreen e a descrição foi atualizada
      expect(find.byType(JournalScreen), findsOneWidget);
      expect(find.text(updatedDescription), findsOneWidget);
      expect(find.text(newDescription), findsNothing); 

      // === 4. DELETE (Exclusão) ===
      
      // 4.1. Tocar na entrada atualizada
      await tester.tap(find.text(updatedDescription));
      await tester.pumpAndSettle();
      expect(find.byType(EditEntryScreen), findsOneWidget);
      
      // 4.2. Tocar no botão de deletar
      await tester.tap(find.byKey(const Key('delete_entry_button')));
      await tester.pumpAndSettle(); 
      
      // 4.3. Confirmar a exclusão no AlertDialog
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.byKey(const Key('confirm_delete_button')));
      await tester.pumpAndSettle(const Duration(seconds: 4)); // Esperar a API
      
      // 4.4. Verificar se voltou para JournalScreen e a entrada sumiu
      expect(find.byType(JournalScreen), findsOneWidget);
      expect(find.text(updatedDescription), findsNothing);
    });
  });
}