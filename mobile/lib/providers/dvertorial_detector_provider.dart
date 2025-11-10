import 'package:flutter/foundation.dart';
import 'package:antibet_app/services/advertorial_detector_service.dart';
import 'package:antibet_app/models/advertorial_detector_models.dart';

/// Gerencia o estado do processo de detecção de advertorial.
///
/// Este provider é responsável por chamar o [AdvertorialDetectorService],
/// armazenar o resultado da análise e controlar os estados de UI
/// (como carregamento e erros).
class AdvertorialDetectorProvider with ChangeNotifier {
  final AdvertorialDetectorService _detectorService;

  // Estado
  bool _isLoading = false;
  String? _errorMessage;
  AdvertorialDetectorResponse? _analysisResult;

  // Seletores (Getters)
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AdvertorialDetectorResponse? get analysisResult => _analysisResult;
  bool get hasError => _errorMessage != null;
  bool get hasResult => _analysisResult != null;

  AdvertorialDetectorProvider({
    // A injeção de dependência permite mockar o serviço nos testes.
    required AdvertorialDetectorService detectorService,
  }) : _detectorService = detectorService;

  /// Ponto de entrada principal para a UI.
  /// Dispara a verificação de URL e conteúdo.
  Future<void> checkUrl(String url, String content) async {
    // 1. Define o estado de carregamento e limpa erros anteriores
    _setLoading(true);
    _clearError();
    _clearResult();

    try {
      // 2. Chama o serviço de API (HTTP Client)
      final response = await _detectorService.checkContent(
        url: url,
        content: content,
      );

      // 3. Armazena o resultado
      _analysisResult = response;
    } catch (e) {
      // 4. Em caso de falha (rede, parsing, etc.)
      debugPrint("Erro em AdvertorialDetectorProvider.checkUrl: $e");
      _errorMessage = "Não foi possível realizar a análise. Tente novamente.";
    } finally {
      // 5. Garante que o loading seja desativado
      _setLoading(false);
    }
  }

  /// Limpa os resultados da análise anterior (ex: ao fechar a UI).
  void clearAnalysis() {
    _clearError();
    _clearResult();
    notifyListeners();
  }

  // --- Métodos privados de controle de estado ---

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      // Não notificamos ouvintes aqui, esperamos o _setLoading ou _clearResult
    }
  }

  void _clearResult() {
    if (_analysisResult != null) {
      _analysisResult = null;
      // Não notificamos ouvintes aqui
    }
  }
}