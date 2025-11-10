import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Importações dos componentes a serem testados e dependências
import 'package:antibet_mobile/core/domain/help_and_alerts_model.dart';
import 'package:antibet_mobile/notifiers/help_and_alerts_notifier.dart';
import 'package:antibet_mobile/presentation/views/help_and_alerts_view.dart';
// Precisamos mockar o url_launcher
import 'package:url_launcher/url_launcher.dart';

// Gera o mock para o HelpAndAlertsNotifier
@GenerateMocks([HelpAndAlertsNotifier])
import 'help_and_alerts_view_test.mocks.dart'; 

void main() {
  late MockHelpAndAlertsNotifier mockNotifier;

  // Lista de teste
  const List<HelpResourceModel> mockResources = [
    HelpResourceModel(
      title: 'CVV - Centro de Valorização da Vida',
      url: 'https://www.cvv.org.br',
      type: 'website',
    ),
    HelpResourceModel(
      title: 'Jogadores Anônimos (JA)',
      url: 'https://jogadoresanonimos.org.br',
      type: 'website',
    ),
    HelpResourceModel(
      title: 'Apoio Telefônico (188)',
      url: '188',
      type: 'phone',
    ),
  ];
  const HelpAndAlertsModel mockModel = HelpAndAlertsModel(supportResources: mockResources);

  setUp(() {
    mockNotifier = MockHelpAndAlertsNotifier();
    
    // Configuração padrão (Estado Carregado)
    when(mockNotifier.state).thenReturn(HelpState.loaded);
    when(mockNotifier.resources).thenReturn(mockResources);
    when(mockNotifier.model).thenReturn(mockModel);
    when(mockNotifier.fetchResources()).thenAnswer((_) async {});
  });

  // Wrapper que simula o ambiente da aplicação (MaterialApp e Provider)
  Widget createHelpScreen({required HelpAndAlertsNotifier notifier}) {
    return MaterialApp(
      home: ChangeNotifierProvider<HelpAndAlertsNotifier>.value(
        value: notifier,
        child: const HelpAndAlertsView(),
      ),
    );
  }

  group('HelpAndAlertsView Widget Tests', () {

    // --- Teste 1: Exibição do Estado Loading ---
    testWidgets('Exibe CircularProgressIndicator no estado loading', (WidgetTester tester) async {
      when(mockNotifier.state).thenReturn(HelpState.loading);
      
      await tester.pumpWidget(createHelpScreen(notifier: mockNotifier));
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // --- Teste 2: Exibição do Estado Error ---
    testWidgets('Exibe mensagem de erro e botão de recarregar no estado error', (WidgetTester tester) async {
      when(mockNotifier.state).thenReturn(HelpState.error);
      when(mockNotifier.errorMessage).thenReturn('Falha de conexão.');

      await tester.pumpWidget(createHelpScreen(notifier: mockNotifier));
      
      expect(find.textContaining('Erro ao carregar recursos de ajuda:'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Recarregar'), findsOneWidget);

      // Toca para tentar novamente
      await tester.tap(find.widgetWithText(ElevatedButton, 'Recarregar'));
      await tester.pump();
      
      verify(mockNotifier.fetchResources()).called(1); // Verifica a chamada do retry
    });

    // --- Teste 3: Exibição da Lista de Recursos ---
    testWidgets('Exibe lista de recursos de ajuda no estado loaded', (WidgetTester tester) async {
      await tester.pumpWidget(createHelpScreen(notifier: mockNotifier));

      // Verifica se o título dos itens da lista estão presentes
      expect(find.text('CVV - Centro de Valorização da Vida'), findsOneWidget);
      expect(find.text('Jogadores Anônimos (JA)'), findsOneWidget);
      expect(find.text('Apoio Telefônico (188)'), findsOneWidget);
      
      // Verifica os ícones (2 websites, 1 telefone)
      expect(find.byIcon(Icons.language), findsNWidgets(2));
      expect(find.byIcon(Icons.phone), findsOneWidget);
      
      // Verifica o ícone de ação
      expect(find.byIcon(Icons.open_in_new), findsNWidgets(3));
    });
    
    // --- Teste 4: Lista Vazia ---
    testWidgets('Exibe mensagem de lista vazia quando loaded mas sem dados', (WidgetTester tester) async {
      when(mockNotifier.state).thenReturn(HelpState.loaded);
      when(mockNotifier.resources).thenReturn([]); // Lista vazia

      await tester.pumpWidget(createHelpScreen(notifier: mockNotifier));

      expect(find.text('Nenhum recurso de ajuda disponível.'), findsOneWidget);
    });
    
    // --- Teste 5: Interação (Abrir URL) ---
    // Nota: Testar url_launcher é complexo. Este teste apenas confirma que a UI está presente
    // e que o ListTile pode ser tocado, sem verificar a chamada estática do plugin.
    testWidgets('Tocar em um item da lista (Website)', (WidgetTester tester) async {
      await tester.pumpWidget(createHelpScreen(notifier: mockNotifier));
      
      final websiteItem = find.text('CVV - Centro de Valorização da Vida');
      expect(websiteItem, findsOneWidget);
      
      // Tenta tocar no item. O teste passa se não houver exceção
      // (a lógica de _launchResource será acionada, mas pode falhar no ambiente de teste)
      await tester.tap(websiteItem);
      await tester.pump();
    });
  });
}