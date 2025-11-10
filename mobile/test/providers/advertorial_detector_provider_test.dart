import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:antibet_app/models/advertorial_detector_models.dart';
import 'package:antibet_app/services/advertorial_detector_service.dart';
import 'package:antibet_app/providers/advertorial_detector_provider.dart';

// Gera o mock com: flutter pub run build_runner build
@GenerateMocks([AdvertorialDetectorService])
import 'advertorial_detector_provider_test.mocks.dart';

void main() {
  late MockAdvertorialDetectorService mockService;
  late AdvertorialDetectorProvider provider;

  setUp(() {
    // 1. Configuração inicial para cada teste
    mockService = MockAdvertorialDetectorService();
    provider = AdvertorialDetectorProvider(detectorService: mockService);
  });

  // --- Mock Data ---
  final tUrl = "https://exemplo.com";
  final tContent = "compre agora";

  final tSuccessResponse = AdvertorialDetectorResponse(
    detector: AdvertorialResult(
      isAdvertorial: true,
      score: 5,
      matchedKeywords: ["compre agora"],
    ),
    spa: SPAScanResult(
      isAuthorized: false,
      domain: "exemplo.com",
    ),
    education: EducationContent(
      priority: 1,
      cardTitle: "Cuidado!",
      cardBody: "Este site parece suspeito.",
    ),
  );

  final tException = Exception("Erro de Rede 500");

  group('AdvertorialDetectorProvider Tests - Q.R.', () {
    test('Estado inicial deve estar limpo e sem loading', () {
      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isFalse);
      expect(provider.hasResult, isFalse);
      expect(provider.analysisResult, isNull);
      expect(provider.errorMessage, isNull);
    });

    test('checkUrl: Cenário de Sucesso (API retorna dados)', () async {
      // 2. Arrange (Configurar o Mock)
      // Quando 'checkContent' for chamado com qualquer argumento,
      // retorne a resposta de sucesso.
      when(mockService.checkContent(url: anyNamed('url'), content: anyNamed('content')))
          .thenAnswer((_) async => tSuccessResponse);

      // Listener para verificar mudanças de estado
      final List<bool> loadingStates = [];
      provider.addListener(() {
        loadingStates.add(provider.isLoading);
      });

      // 3. Act (Executar a ação)
      final future = provider.checkUrl(tUrl, tContent);

      // 4. Assert (Verificar estados durante a execução)
      // Estado inicial (antes do 'await')
      expect(provider.isLoading, isTrue);
      expect(provider.hasError, isFalse);

      // Aguarda a conclusão
      await future;

      // Assert (Verificar estado final)
      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isFalse);
      expect(provider.hasResult, isTrue);
      expect(provider.analysisResult, equals(tSuccessResponse));
      expect(provider.errorMessage, isNull);

      // Verifica a sequência de loading (True -> False)
      expect(loadingStates, [true, false]);
    });

    test('checkUrl: Cenário de Falha (API lança Exceção)', () async {
      // 2. Arrange (Configurar o Mock para lançar erro)
      when(mockService.checkContent(url: anyNamed('url'), content: anyNamed('content')))
          .thenThrow(tException);

      // Listener
      final List<bool> loadingStates = [];
      provider.addListener(() {
        loadingStates.add(provider.isLoading);
      });

      // 3. Act
      await provider.checkUrl(tUrl, tContent);

      // 4. Assert (Verificar estado final)
      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isTrue);
      expect(provider.hasResult, isFalse);
      expect(provider.analysisResult, isNull);
      expect(provider.errorMessage, isNotNull);
      expect(provider.errorMessage, "Não foi possível realizar a análise. Tente novamente.");

      // Verifica a sequência de loading (True -> False)
      expect(loadingStates, [true, false]);
    });

    test('clearAnalysis deve limpar o estado de resultado e erro', () async {
      // 1. Arrange (Coloca o provider em estado de sucesso)
      when(mockService.checkContent(url: anyNamed('url'), content: anyNamed('content')))
          .thenAnswer((_) async => tSuccessResponse);
      await provider.checkUrl(tUrl, tContent);
      
      // Verifica se o estado está "sujo"
      expect(provider.hasResult, isTrue);
      
      // 2. Act
      provider.clearAnalysis();
      
      // 3. Assert
      expect(provider.hasResult, isFalse);
      expect(provider.analysisResult, isNull);
      expect(provider.hasError, isFalse); // clearAnalysis também limpa erros
      expect(provider.errorMessage, isNull);
      expect(provider.isLoading, isFalse); // Não deve estar carregando
    });
  });
}