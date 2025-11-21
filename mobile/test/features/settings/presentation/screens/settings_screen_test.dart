import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:antibet/features/settings/data/models/user_settings_model.dart';
import 'package:antibet/features/settings/presentation/providers/user_settings_provider.dart';
import 'package:antibet/features/settings/presentation/screens/settings_screen.dart';

// Mocks
class MockSettingsNotifier extends StateNotifier<AsyncValue<UserSettingsModel>> with Mock implements UserSettingsNotifier {
  // Inicializa com dados para que a UI possa ser construída
  MockSettingsNotifier() : super(AsyncValue.data(UserSettingsModel.initial()));
  
  @override
  Future<void> updateSettings({
    bool? isDarkMode,
    bool? enableNotifications,
    String? preferredCurrency,
  }) async {}

  @override
  Future<void> clearSettings() async {}
  
  // Método auxiliar para simular estados de carregamento ou erro
  void setState(AsyncValue<UserSettingsModel> newState) {
    state = newState;
  }
}

// Wrapper para simular o ProviderScope
class TestSettingsWrapper extends StatelessWidget {
  final Widget child;
  final MockSettingsNotifier mockNotifier;

  const TestSettingsWrapper({super.key, required this.child, required this.mockNotifier});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        userSettingsProvider.overrideWithValue(mockNotifier),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }
}

void main() {
  late MockSettingsNotifier mockNotifier;

  setUp(() {
    mockNotifier = MockSettingsNotifier();
    
    // Configuração dos mocks para os métodos de atualização
    when(() => mockNotifier.updateSettings(
          isDarkMode: any(named: 'isDarkMode'),
          enableNotifications: any(named: 'enableNotifications'),
          preferredCurrency: any(named: 'preferredCurrency'),
        )).thenAnswer((_) async {});
    
    when(() => mockNotifier.clearSettings()).thenAnswer((_) async {});
  });

  group('SettingsScreen Widget Test', () {
    testWidgets('should show CircularProgressIndicator when loading', (WidgetTester tester) async {
      // Arrange
      mockNotifier.setState(const AsyncValue.loading());
      
      await tester.pumpWidget(TestSettingsWrapper(
        child: const SettingsScreen(),
        mockNotifier: mockNotifier,
      ));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show settings options when data is available', (WidgetTester tester) async {
      // Arrange
      mockNotifier.setState(AsyncValue.data(const UserSettingsModel(
        isDarkMode: true,
        enableNotifications: false,
        preferredCurrency: 'BRL',
      )));
      
      await tester.pumpWidget(TestSettingsWrapper(
        child: const SettingsScreen(),
        mockNotifier: mockNotifier,
      ));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Modo Escuro'), findsOneWidget);
      expect(find.text('Notificações'), findsOneWidget);
      expect(find.text('Atualmente: BRL'), findsOneWidget);
      
      // Verifica o estado inicial do Switch de Dark Mode
      final darkModeSwitch = tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, 'Modo Escuro'));
      expect(darkModeSwitch.value, true); 

      // Verifica o botão de reset
      expect(find.text('RESETAR CONFIGURAÇÕES'), findsOneWidget);
    });

    testWidgets('tapping Dark Mode switch calls updateSettings with correct value', (WidgetTester tester) async {
      // Arrange
      mockNotifier.setState(AsyncValue.data(UserSettingsModel.initial())); // isDarkMode: false
      
      await tester.pumpWidget(TestSettingsWrapper(
        child: const SettingsScreen(),
        mockNotifier: mockNotifier,
      ));
      await tester.pumpAndSettle();

      // Act
      // Toca no switch para mudar para true
      await tester.tap(find.widgetWithText(SwitchListTile, 'Modo Escuro'));
      await tester.pump(); 

      // Assert
      // Verifica se o Notifier foi chamado com o valor correto (false -> true)
      verify(() => mockNotifier.updateSettings(isDarkMode: true)).called(1);
    });
    
    testWidgets('tapping RESET CONFIGURAÇÕES calls clearSettings', (WidgetTester tester) async {
      // Arrange
      mockNotifier.setState(AsyncValue.data(tSettings)); 
      
      await tester.pumpWidget(TestSettingsWrapper(
        child: const SettingsScreen(),
        mockNotifier: mockNotifier,
      ));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('RESETAR CONFIGURAÇÕES'));
      await tester.pump(); 

      // Assert
      verify(() => mockNotifier.clearSettings()).called(1);
    });
  });
}