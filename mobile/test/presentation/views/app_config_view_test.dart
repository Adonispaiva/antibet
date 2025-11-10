import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Importações dos componentes a serem testados e dependências
import 'package:antibet_mobile/core/domain/app_config_model.dart';
import 'package:antibet_mobile/notifiers/app_config_notifier.dart';
import 'package:antibet_mobile/presentation/views/app_config_view.dart';

// Gera o mock para o AppConfigNotifier
@GenerateMocks([AppConfigNotifier])
import 'app_config_view_test.mocks.dart'; 

void main() {
  late MockAppConfigNotifier mockNotifier;

  // Configuração padrão de teste (Modo Claro, Notificações Ativadas)
  const AppConfigModel initialConfig = kDefaultAppConfig;

  setUp(() {
    mockNotifier = MockAppConfigNotifier();
    // Configura o mock para retornar a configuração padrão
    when(mockNotifier.config).thenReturn(initialConfig);
    when(mockNotifier.isDarkMode).thenReturn(initialConfig.isDarkMode);
    when(mockNotifier.areNotificationsEnabled).thenReturn(initialConfig.areNotificationsEnabled);
  });

  // Wrapper que simula o ambiente da aplicação (MaterialApp e Provider)
  Widget createAppConfigScreen({required AppConfigNotifier notifier}) {
    return MaterialApp(
      home: ChangeNotifierProvider<AppConfigNotifier>.value(
        value: notifier,
        child: const AppConfigView(),
      ),
    );
  }

  group('AppConfigView Widget Tests', () {

    // Helper para encontrar os switches
    Finder findDarkModeSwitch() => find.widgetWithText(SwitchListTile, 'Modo Escuro (Dark Mode)');
    Finder findNotificationsSwitch() => find.widgetWithText(SwitchListTile, 'Receber Notificações');

    // --- Teste 1: Estrutura Básica e Valores Iniciais ---
    testWidgets('View exibe todos os switches com valores iniciais corretos', (WidgetTester tester) async {
      await tester.pumpWidget(createAppConfigScreen(notifier: mockNotifier));

      expect(find.text('Configurações'), findsOneWidget);
      expect(findDarkModeSwitch(), findsOneWidget);
      expect(findNotificationsSwitch(), findsOneWidget);
      
      // Verifica o estado inicial dos switches (Modo Escuro: false, Notificações: true)
      final darkModeSwitch = tester.widget<SwitchListTile>(findDarkModeSwitch());
      expect(darkModeSwitch.value, isFalse); 

      final notificationsSwitch = tester.widget<SwitchListTile>(findNotificationsSwitch());
      expect(notificationsSwitch.value, isTrue); 
    });

    // --- Teste 2: Alteração do Modo Escuro ---
    testWidgets('Tocar no switch de Dark Mode chama updateConfig(isDarkMode: true)', (WidgetTester tester) async {
      when(mockNotifier.updateConfig(isDarkMode: anyNamed('isDarkMode'))).thenAnswer((_) async {});
      
      await tester.pumpWidget(createAppConfigScreen(notifier: mockNotifier));

      // Toca no switch
      await tester.tap(findDarkModeSwitch());
      
      // Simula a mudança de estado que o Notifier faria para true
      when(mockNotifier.isDarkMode).thenReturn(true); 
      await tester.pump(); // Reconstrução da UI

      // Verifica se o método de atualização foi chamado com o valor correto
      verify(mockNotifier.updateConfig(isDarkMode: true)).called(1);

      // Verifica se o switch está visualmente ligado após o pump
      final darkModeSwitch = tester.widget<SwitchListTile>(findDarkModeSwitch());
      expect(darkModeSwitch.value, isTrue); 
    });

    // --- Teste 3: Alteração das Notificações ---
    testWidgets('Tocar no switch de Notificações chama updateConfig(areNotificationsEnabled: false)', (WidgetTester tester) async {
      when(mockNotifier.updateConfig(areNotificationsEnabled: anyNamed('areNotificationsEnabled'))).thenAnswer((_) async {});
      
      await tester.pumpWidget(createAppConfigScreen(notifier: mockNotifier));

      // Toca no switch
      await tester.tap(findNotificationsSwitch());
      
      // Simula a mudança de estado que o Notifier faria para false
      when(mockNotifier.areNotificationsEnabled).thenReturn(false); 
      await tester.pump(); // Reconstrução da UI

      // Verifica se o método de atualização foi chamado com o valor correto
      verify(mockNotifier.updateConfig(areNotificationsEnabled: false)).called(1);

      // Verifica se o switch está visualmente desligado
      final notificationsSwitch = tester.widget<SwitchListTile>(findNotificationsSwitch());
      expect(notificationsSwitch.value, isFalse); 
    });
  });
}