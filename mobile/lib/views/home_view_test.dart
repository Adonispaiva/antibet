import 'package:antibet_mobile/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Define um grupo de testes para a HomeView
  group('HomeView Widget Tests', () {
    
    // Testa se a HomeView é renderizada corretamente e se o título está presente.
    testWidgets('Deve exibir o título da App Bar e o texto de boas-vindas', (WidgetTester tester) async {
      // 1. Arrange: Monta o widget sob teste.
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeView(),
        ),
      );

      // 2. Act: Nenhuma interação é necessária neste teste, apenas a renderização inicial (pump).

      // 3. Assert: Verifica se os Finders encontram os elementos esperados.

      // Verifica se o título da App Bar está presente.
      final titleFinder = find.text('AntiBet - Autocontrole');
      expect(titleFinder, findsOneWidget, reason: 'O título da App Bar deve ser encontrado.');

      // Verifica se o texto principal de boas-vindas (placeholder) está presente.
      final welcomeTextFinder = find.text('Bem-vindo ao AntiBet!');
      expect(welcomeTextFinder, findsOneWidget, reason: 'O texto de boas-vindas deve ser encontrado.');
      
      // Opcional: Verifica se o ícone 'settings' (que está comentado mas é uma boa prática) não está presente.
      final settingsIconFinder = find.byIcon(Icons.settings);
      expect(settingsIconFinder, findsNothing, reason: 'O ícone de configurações não deve estar presente (com base no código atual).');
    });

    // Outros testes podem ser adicionados aqui (Ex: Testar a navegação, interações de botões, etc.)
  });
}