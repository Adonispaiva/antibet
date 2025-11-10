import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:http/testing.dart';

import 'package:antibet/src/core/services/advertorial_detector_service.dart';

// --- Mocks JSON (Simulando a Resposta da API FastAPI) ---

// Cenário 1: Risco Alto (Advertorial + Operadoras Autorizadas e Não Autorizadas)
final mockApiResponseRiscoAlto = json.encode({
  "score": 85,
  "risk_label": "Alto",
  "advertorial_evidence": {
    "DECEPTIVE_MATCHES": ["hack do tigrinho"],
    "OPERATOR_MATCHES": ["betano", "blaze"]
  },
  "spa_verification": [
    {"domain": "betano", "status": "AUTHORIZED", "details": {"company_name": "Kaizen"}},
    {"domain": "blaze", "status": "UNKNOWN_OR_UNAUTHORIZED", "details": null}
  ],
  "url_analyzed": "https://portal-exemplo.com/publieditorial/como-ganhar-facil"
});

// Cenário 2: Risco Baixo (Conteúdo Legítimo)
final mockApiResponseRiscoBaixo = json.encode({
  "score": 0,
  "risk_label": "Baixo",
  "advertorial_evidence": {},
  "spa_verification": [],
  "url_analyzed": "https://portal-legitimo.com/noticia/economia"
});


void main() {
  late AdvertorialDetectorService service;
  late http.Client mockClient;

  group('AdvertorialDetectorService (Frontend) Tests', () {
    
    test('checkAdvertorialRisk should parse HIGH RISK report correctly (HTTP 200)', () async {
      // Setup: Configura o MockClient para retornar o JSON de Risco Alto
      mockClient = MockClient((request) async {
        // Valida se o endpoint correto foi chamado
        expect(request.url.path, equals('/api/v1/detector/check'));
        return http.Response(utf8.decode(mockApiResponseRiscoAlto.codeUnits), 200, headers: {
          'Content-Type': 'application/json; charset=utf-8',
        });
      });

      service = AdvertorialDetectorService(client: mockClient);
      
      // A URL de entrada define o mock de scraping no serviço
      final report = await service.checkAdvertorialRisk("https://portal-exemplo.com/betano");

      // Verificações
      expect(report, isNotNull);
      
      // 1. Validação do Score (Card 1)
      expect(report!.score, 85);
      expect(report.riskLabel, "Alto");
      expect(report.advertorialEvidence["DECEPTIVE_MATCHES"], isNotEmpty);
      
      // 2. Validação da Verificação SPA (Card 2)
      expect(report.spaVerification.length, 2);
      final spaBlaze = report.spaVerification.firstWhere((s) => s.domain == "blaze");
      final spaBetano = report.spaVerification.firstWhere((s) => s.domain == "betano");
      
      expect(spaBlaze.status, "UNKNOWN_OR_UNAUTHORIZED");
      expect(spaBetano.status, "AUTHORIZED");
      expect(spaBetano.details!["company_name"], "Kaizen");
    });

    test('checkAdvertorialRisk should parse LOW RISK report correctly (HTTP 200)', () async {
      // Setup: Configura o MockClient para retornar o JSON de Risco Baixo
      mockClient = MockClient((request) async {
        return http.Response(utf8.decode(mockApiResponseRiscoBaixo.codeUnits), 200, headers: {
          'Content-Type': 'application/json; charset=utf-8',
        });
      });

      service = AdvertorialDetectorService(client: mockClient);
      
      // A URL de entrada define o mock de scraping no serviço
      final report = await service.checkAdvertorialRisk("https://portal-legitimo.com/noticia");

      // Verificações
      expect(report, isNotNull);
      expect(report!.score, 0);
      expect(report.riskLabel, "Baixo");
      expect(report.advertorialEvidence, isEmpty);
      expect(report.spaVerification, isEmpty);
    });

    test('checkAdvertorialRisk should return null on API failure (HTTP 500)', () async {
      // Setup: Configura o MockClient para retornar erro
      mockClient = MockClient((request) async {
        return http.Response("Internal Server Error", 500);
      });

      service = AdvertorialDetectorService(client: mockClient);
      
      final report = await service.checkAdvertorialRisk("https://portal-exemplo.com");
      
      // Verificação: Deve retornar nulo em caso de falha
      expect(report, isNull);
    });
  });
}