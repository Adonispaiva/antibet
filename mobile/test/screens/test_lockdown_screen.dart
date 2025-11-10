import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:antibet_app/notifiers/lockdown_notifier.dart';
import 'package:antibet_app/screens/lockdown_screen.dart';

// Importa o mock gerado do notificador (Assumindo que foi gerado pelo test_lockdown_notifier.dart)
import '../notifiers/test_lockdown_notifier.mocks.dart'; 

void main() {
  late MockLockdownNotifier mockNotifier;

  // Wrapper para injetar o mockNotifier no Widget
  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<LockdownNotifier>.value(
        value: mockNotifier,
        child: const LockdownScreen(),
      ),
    );
  }

  setUp(() {
    mockNotifier = MockLockdownNotifier();
    
    // Comportamento padrão (sem bloqueio)
    when(mockNotifier.isInLockdown).thenReturn(false);
    when(mockNotifier.lockdownEndTime).thenReturn(null);
    when(mockNotifier.addListener(any)).thenReturn(null);
  });

  group('LockdownScreen Widget Test - Q.R. (Anti-Vício UI)', () {
    
    testWidgets('Deve exibir o titulo de bloqueio e o icone de segurança', (tester) async {
      // 1. Arrange: Estado de Bloqueio Ativo
      final futureTime = DateTime.now().add(const Duration(hours: 10));
      when(mockNotifier.isInLockdown).thenReturn(true);
      when(mockNotifier.lockdownEndTime).thenReturn(futureTime);
      
      // 2. Act
      await tester.pumpWidget(createWidgetUnderTest());
      
      // 3. Assert
      expect(find.text('ACESSO BLOQUEADO POR SEGURANÇA'), findsOneWidget);
      expect(find.text('Bloqueio Ativo (Missão Anti-Vício)'), findsOneWidget);
      expect(find.byIcon(Icons.security_update_disabled_rounded), findsOneWidget);
    });

    testWidgets('Deve exibir o tempo de término do bloqueio formatado', (tester) async {
      // 1. Arrange: Define um tempo de término fixo (Ex: 09/11/2025 às 14:30:00)
      final fixedEndTime = DateTime(2025, 11, 9, 14, 30, 0); 
      when(mockNotifier.isInLockdown).thenReturn(true);
      when(mockNotifier.lockdownEndTime).thenReturn(fixedEndTime);
      
      // 2. Act
      await tester.pumpWidget(createWidgetUnderTest());
      
      // 3. Assert: Verifica se a string formatada aparece (depende da localidade, mas a parte chave deve ser detectável)
      // Ajuste o texto esperado para ser robusto (verifica a presença de 'Seu bloqueio termina em')
      expect(find.textContaining('Seu bloqueio termina em:'), findsOneWidget);
      // Verifica o formato básico de data e hora
      expect(find.textContaining('14:30:00'), findsOneWidget); 
    });

    testWidgets('Botao de Debug deve chamar activateLockdown no Notifier', (tester) async {
      // 1. Arrange: Estado normal
      when(mockNotifier.activateLockdown()).thenAnswer((_) async {});
      
      // 2. Act
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Toca o botão 'Ativar 24h de Bloqueio (Debug)'
      await tester.tap(find.text('Ativar 24h de Bloqueio (Debug)'));
      await tester.pump();
      
      // 3. Assert
      // Verifica se o método de negócio foi chamado
      verify(mockNotifier.activateLockdown()).called(1);
    });
    
    testWidgets('Deve exibir mensagem padrao se lockdownEndTime for nulo (mesmo estando em lockdown)', (tester) async {
      // 1. Arrange: Configura para estar em lockdown, mas sem tempo definido (erro)
      when(mockNotifier.isInLockdown).thenReturn(true); 
      when(mockNotifier.lockdownEndTime).thenReturn(null);
      
      // 2. Act
      await tester.pumpWidget(createWidgetUnderTest());
      
      // 3. Assert
      expect(find.textContaining('O bloqueio está ativo, mas o tempo de término não foi definido.'), findsOneWidget);
    });
  });
}