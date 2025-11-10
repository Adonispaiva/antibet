import 'dart:convert';
import 'package:http/http.dart' as http;

// --- Modelos de Dados (DTOs) ---
// Representam a resposta da API (DetectResponse em advertorial_detector_router.py)

class SPAStatus {
  final String domain;
  final String status; // "AUTHORIZED" ou "UNKNOWN_OR_UNAUTHORIZED"
  final Map<String, dynamic>? details;

  SPAStatus({required this.domain, required this.status, this.details});

  factory SPAStatus.fromJson(Map<String, dynamic> json) {
    return SPAStatus(
      domain: json['domain'],
      status: json['status'],
      details: json['details'],
    );
  }
}

class AdvertorialReport {
  final int score;
  final String riskLabel; // "Baixo", "Moderado", "Alto"
  final Map<String, dynamic> advertorialEvidence;
  final List<SPAStatus> spaVerification;
  final String urlAnalyzed;

  AdvertorialReport({
    required this.score,
    required this.riskLabel,
    required this.advertorialEvidence,
    required this.spaVerification,
    required this.urlAnalyzed,
  });

  factory AdvertorialReport.fromJson(Map<String, dynamic> json) {
    var spaList = (json['spa_verification'] as List)
        .map((i) => SPAStatus.fromJson(i))
        .toList();
    
    return AdvertorialReport(
      score: json['score'],
      riskLabel: json['risk_label'],
      advertorialEvidence: json['advertorial_evidence'],
      spaVerification: spaList,
      urlAnalyzed: json['url_analyzed'],
    );
  }
}

class AdvertorialDetectorService {
  // URL base da API Backend (FastAPI)
  final String _baseUrl = "http://127.0.0.1:8000/api/v1/detector";
  final http.Client _client;

  AdvertorialDetectorService({http.Client? client}) : _client = client ?? http.Client();

  /// Simula a extração de conteúdo (scraping) de uma URL.
  /// (Conforme Card 1, o scraping deve ocorrer antes de enviar para a API de detecção)
  Future<String> _scrapeTextContent(String url) async {
    // Simulação de scraping. Em produção, usaria um pacote como 'web_scraper'
    // ou 'flutter_inappwebview' para extrair o 'body.text'.
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Simulação baseada na URL (para testes)
    if (url.contains("betano") || url.contains("blaze")) {
      return "Este é um conteúdo patrocinado. A melhor estratégia infalível é usar o hack do tigrinho. Cadastre-se na Betano agora e ganhe bônus!";
    }
    return "Este é um artigo normal sobre economia e taxas de juros.";
  }

  /// Chama a API do Backend para verificar o risco de advertorial de uma URL.
  ///
  Future<AdvertorialReport?> checkAdvertorialRisk(String url) async {
    try {
      // 1. Simula o scraping do conteúdo (Card 1)
      final String textContent = await _scrapeTextContent(url);
      
      final response = await _client.post(
        Uri.parse("$_baseUrl/check"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-R',
        },
        body: json.encode({
          'url': url,
          'text_content': textContent,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(utf8.decode(response.bodyBytes));
        return AdvertorialReport.fromJson(responseBody);
      } else {
        print("Erro na API do Detector: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Erro ao chamar o AdvertorialDetectorService: $e");
      return null;
    }
  }
}