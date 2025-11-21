import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:antibet/features/journal/data/models/journal_model.dart';
import 'package:antibet/features/journal/presentation/widgets/journal_stats.dart';

void main() {
  testWidgets('JournalStats displays correct summary data', (WidgetTester tester) async {
    // Arrange
    const tJournal = JournalModel(
      entries: [], // Entradas não são usadas diretamente no widget de stats, apenas os totais
      totalInvested: 150.50,
      totalWins: 5,
      totalLosses: 2,
    );

    // Act
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: JournalStats(journal: tJournal),
        ),
      ),
    );

    // Assert
    // Verifica se o título e labels estão presentes
    expect(find.text('Resumo do Diário'), findsOneWidget);
    expect(find.text('Investido'), findsOneWidget);
    expect(find.text('Wins'), findsOneWidget);
    expect(find.text('Losses'), findsOneWidget);

    // Verifica se os valores formatados estão corretos
    expect(find.text('R\$ 150.50'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });
}