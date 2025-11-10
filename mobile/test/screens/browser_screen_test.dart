import 'package:antibet_app/models/advertorial_detector_models.dart';
import 'package:antibet_app/providers/advertorial_detector_provider.dart';
import 'package:antibet_app/screens/browser_screen.dart';
import 'package:antibet_app/services/advertorial_detector_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Importa o mock gerado no teste do provider
import '../providers/advertorial_detector_provider_test.mocks.dart';

// --- Mock Data Globals ---
final tSuccessResponseAdvertorial = AdvertorialDetectorResponse(
  detector: AdvertorialResult(isAdvertorial: true, score: 5, matchedKeywords: ["garantido"]),
  spa: SPAScanResult(isAuthorized: false, domain: "exemplo.com"),
  education: EducationContent(priority: 2, cardTitle: "Cuidado! Risco Alto", cardBody: "..."),
);

final tSuccessResponseSpaAuthorized = AdvertorialDetectorResponse(
  detector: AdvertorialResult(isAdvertorial: false, score: 0, matchedKeywords: []),
  spa: SPAScanResult(isAuthorized: true, domain: "app.exemplo-autorizado.com"),
  education: EducationContent(priority: 0, cardTitle: "", cardBody: ""),
);

// --- Testes ---

void main() {
  late MockAdvertorialDetectorService mockService;
  late AdvertorialDetectorProvider mockProvider;

  // Wrapper de teste reutilizável
  Widget createWidgetUnderTest(AdvertorialDetectorProvider provider) {
    return ChangeNotifierProvider<AdvertorialDetectorProvider>.value(
      value: provider,
      child: const MaterialApp(
        home: BrowserScreen(),
      ),
    );
  }

  setUp(() {
    // Usamos o MockService para instanciar o Provider real
    mockService = MockAdvertorialDetectorService();
    mockProvider = AdvertorialDetectorProvider(detectorService: mockService);
  });

  group('BrowserScreen Widget Test (Q.R. - Card 3 Integration)', () {

    testWidgets('Estado Inicial (sem ação): Não deve exibir nada', 
        (WidgetTester tester) async {
      // 1. Arrange
      // O provider está no estado inicial (isLoading: false, hasResult: false)
      
      // 2. Act
      await tester.pumpWidget(createWidgetUnderTest(mockProvider));
      
      // 3. Assert
      // O AdvertorialWarningCard retorna SizedBox.shrink
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('Estado de Loading: Deve exibir CircularProgressIndicator', 
        (WidgetTester tester) async {
      // 1. Arrange
      // Força o estado de loading no mock provider
      when(mockService.checkContent(url: anyNamed('url'), content: anyNamed('content')))
          .thenAnswer((_) async {
        // Simula a demora da rede
        await Future.delayed(const Duration(milliseconds: 100));
        return tSuccessResponseAdvertorial;
      });
      
      // Dispara a ação (mas não esperamos) e forçamos o estado no provider
      mockProvider.checkUrl("url", "content");
      
      // 2. Act
      await tester.pumpWidget(createWidgetUnderTest(mockProvider));
      
      // 3. Assert
      // O provider deve estar em loading=true
      expect(mockProvider.isLoading, isTrue);
      // O WarningCard deve renderizar o loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Estado de Erro: Deve exibir o Card de Erro', 
        (WidgetTester tester) async {
      // 1. Arrange
      // Força o estado de erro
      when(mockService.checkContent(url: anyNamed('url'), content: anyNamed('content')))
          .thenThrow(Exception("Falha de rede"));
      
      // Dispara e espera a conclusão (para o erro ser setado)
      await mockProvider.checkUrl("url", "content");
      
      // 2. Act
      await tester.pumpWidget(createWidgetUnderTest(mockProvider));
      
      // 3. Assert
      expect(mockProvider.hasError, isTrue);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text("Não foi possível realizar a análise. Tente novamente."), findsOneWidget);
    });

    testWidgets('Estado de Sucesso (Advertorial): Deve exibir o Card de Aviso', 
        (WidgetTester tester) async {
      // 1. Arrange
      when(mockService.checkContent(url: anyNamed('url'), content: anyNamed('content')))
          .thenAnswer((_) async => tSuccessResponseAdvertorial);

      await mockProvider.checkUrl("url", "content");
      
      // 2. Act
      await tester.pumpWidget(createWidgetUnderTest(mockProvider));
      
      // 3. Assert
      expect(mockProvider.hasResult, isTrue);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget); // Ícone de prioridade 2
      expect(find.text("Cuidado! Risco Alto"), findsOneWidget);
    });

    testWidgets('Estado de Sucesso (SPA Autorizado): Não deve exibir nada (SizedBox.shrink)', 
        (WidgetTester tester) async {
      // 1. Arrange
      when(mockService.checkContent(url: anyNamed('url'), content: anyNamed('content')))
          .thenAnswer((_) async => tSuccessResponseSpaAuthorized);

      await mockProvider.checkUrl("url", "content");
      
      // 2. Act
      await tester.pumpWidget(createWidgetUnderTest(mockProvider));
      
      // 3. Assert
      expect(mockProvider.hasResult, isTrue);
      // O resultado é um SPA Autorizado, então o WarningCard retorna SizedBox.shrink
      expect(find.byType(Card), findsNothing);
      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
      expect(find.byIcon(Icons.info_outline_rounded), findsNothing);
    });
  });
}