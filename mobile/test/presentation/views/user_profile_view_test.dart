import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Importações dos componentes a serem testados e dependências
import 'package:antibet_mobile/core/domain/user_profile_model.dart';
import 'package:antibet_mobile/notifiers/user_profile_notifier.dart';
import 'package:antibet_mobile/presentation/views/user_profile_view.dart';

// Gera o mock para o UserProfileNotifier
@GenerateMocks([UserProfileNotifier])
import 'user_profile_view_test.mocks.dart'; 

void main() {
  late MockUserProfileNotifier mockNotifier;

  const UserProfileModel loadedProfile = UserProfileModel(
    userId: '1',
    fullName: 'Orion Engineer',
    phoneNumber: '1199887766',
    dateOfBirth: null,
  );

  setUp(() {
    mockNotifier = MockUserProfileNotifier();
    // Configura o fetchProfile para não falhar (apenas o teste de erro lida com isso)
    when(mockNotifier.fetchProfile()).thenAnswer((_) async {}); 
  });

  // Widget Wrapper que simula o ambiente da aplicação (MaterialApp e Provider)
  Widget createProfileScreen({required UserProfileNotifier notifier}) {
    return MaterialApp(
      home: ChangeNotifierProvider<UserProfileNotifier>.value(
        value: notifier,
        child: const UserProfileView(),
      ),
    );
  }

  group('UserProfileView Widget Tests', () {

    // Helper para encontrar o botão de edição/salvar
    Finder findEditButton() => find.byIcon(Icons.edit);
    Finder findSaveButton() => find.byIcon(Icons.save);
    Finder findFullNameField() => find.widgetWithText(TextFormField, 'Nome Completo');

    // --- Teste 1: Chamada de Fetch Inicial ---
    testWidgets('View chama fetchProfile() na inicialização', (WidgetTester tester) async {
      when(mockNotifier.state).thenReturn(ProfileState.initial);
      
      await tester.pumpWidget(createProfileScreen(notifier: mockNotifier));
      
      // O fetchProfile é chamado no initState, que é executado durante o pump.
      // pump precisa ser chamado 2x para WidgetsBinding.instance.addPostFrameCallback
      verify(mockNotifier.fetchProfile()).called(1);
    });

    // --- Teste 2: Exibição do Estado Loading ---
    testWidgets('Exibe CircularProgressIndicator no estado loading', (WidgetTester tester) async {
      when(mockNotifier.state).thenReturn(ProfileState.loading);
      
      await tester.pumpWidget(createProfileScreen(notifier: mockNotifier));
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Form), findsNothing);
    });

    // --- Teste 3: Exibição do Estado Error ---
    testWidgets('Exibe mensagem de erro e botão de tentar novamente no estado error', (WidgetTester tester) async {
      when(mockNotifier.state).thenReturn(ProfileState.error);
      when(mockNotifier.errorMessage).thenReturn('Token expirado');

      await tester.pumpWidget(createProfileScreen(notifier: mockNotifier));
      
      expect(find.text('Erro: Token expirado'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Tentar Novamente'), findsOneWidget);

      // Toca para tentar novamente
      await tester.tap(find.widgetWithText(ElevatedButton, 'Tentar Novamente'));
      await tester.pump();
      
      verify(mockNotifier.fetchProfile()).called(2); // Chamado 1 na inicialização, 1 no retry
    });

    // --- Teste 4: Exibição de Dados e Modo de Leitura ---
    testWidgets('Exibe dados do perfil no modo de leitura (não editável)', (WidgetTester tester) async {
      when(mockNotifier.state).thenReturn(ProfileState.loaded);
      when(mockNotifier.userProfile).thenReturn(loadedProfile);

      await tester.pumpWidget(createProfileScreen(notifier: mockNotifier));

      // Deve estar no modo de leitura
      expect(tester.widget<TextFormField>(findFullNameField()).enabled, isFalse);
      expect(find.byType(IconButton), findsOneWidget); // Botão de Edit
      expect(findEditButton(), findsOneWidget);
      expect(findSaveButton(), findsNothing);
      
      // Verifica se os dados estão nos campos
      expect(tester.widget<TextFormField>(findFullNameField()).controller!.text, 'Orion Engineer');
    });

    // --- Teste 5: Transição para Modo de Edição ---
    testWidgets('Transiciona para o modo de edição ao tocar no ícone de editar', (WidgetTester tester) async {
      when(mockNotifier.state).thenReturn(ProfileState.loaded);
      when(mockNotifier.userProfile).thenReturn(loadedProfile);

      await tester.pumpWidget(createProfileScreen(notifier: mockNotifier));
      
      // Entra no modo de edição
      await tester.tap(findEditButton());
      await tester.pump();

      // Verifica que o modo de edição está ativo
      expect(tester.widget<TextFormField>(findFullNameField()).enabled, isTrue);
      expect(findEditButton(), findsNothing);
      expect(findSaveButton(), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Salvar Alterações'), findsOneWidget);
    });
    
    // --- Teste 6: Atualização Bem-Sucedida ---
    testWidgets('Atualização de perfil chama updateProfile() e volta para modo de leitura', (WidgetTester tester) async {
      when(mockNotifier.state).thenReturn(ProfileState.loaded);
      when(mockNotifier.userProfile).thenReturn(loadedProfile);
      // Simula sucesso na atualização
      when(mockNotifier.updateProfile(fullName: anyNamed('fullName'), phoneNumber: anyNamed('phoneNumber'), dateOfBirth: anyNamed('dateOfBirth'))).thenAnswer((_) async {});


      await tester.pumpWidget(createProfileScreen(notifier: mockNotifier));
      await tester.tap(findEditButton()); // Entra em modo de edição
      await tester.pump();
      
      const newName = 'Novo Nome Orion';
      await tester.enterText(findFullNameField(), newName);

      // Toca no botão de salvar
      await tester.tap(findSaveButton());
      await tester.pump(); // Inicia o estado de loading (se houvesse)
      await tester.pumpAndSettle(); // Aguarda a conclusão da atualização

      // Verifica se o método correto foi chamado
      verify(mockNotifier.updateProfile(
        fullName: newName,
        phoneNumber: '1199887766', // Valor original do controller
        dateOfBirth: null,
      )).called(1);

      // Verifica se o modo de leitura foi restaurado (botão de editar visível)
      expect(findEditButton(), findsOneWidget);
      expect(findSaveButton(), findsNothing);
    });
  });
}