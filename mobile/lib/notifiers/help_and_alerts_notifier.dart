import 'package.flutter/foundation.dart';

// Importações dos modelos e serviços
import '../core/domain/help_and_alerts_model.dart'; 
import '../infra/services/help_and_alerts_service.dart';

/// Enum para representar os estados possíveis do Módulo de Ajuda.
enum HelpState {
  initial, 
  loading,
  loaded,
  error
}

/// O Notifier de Alertas e Ajuda gere o estado dos recursos de apoio e a lógica de alerta.
/// Este é um componente central para a Missão Anti-Vício.
class HelpAndAlertsNotifier with ChangeNotifier {
  final HelpAndAlertsService _alertsService;

  HelpAndAlertsModel? _model;
  HelpState _state = HelpState.initial;
  String? _errorMessage;

  HelpAndAlertsNotifier(this._alertsService);

  // Getters Públicos
  HelpAndAlertsModel? get model => _model;
  List<HelpResourceModel> get resources => _model?.supportResources ?? [];
  HelpState get state => _state;
  String? get errorMessage => _errorMessage;

  void _setState(HelpState newState) {
    _state = newState;
    _errorMessage = null; 
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = HelpState.error;
    notifyListeners();
  }

  /// Busca os recursos de ajuda na infraestrutura (links, telefones).
  Future<void> fetchResources() async {
    _setState(HelpState.loading);
    try {
      final fetchedModel = await _alertsService.fetchResources();
      _model = fetchedModel;
      _setState(HelpState.loaded);
    } on AlertsServiceException catch (e) {
      _setError('Falha ao carregar recursos de ajuda: ${e.message}');
    } catch (e) {
      _setError('Erro desconhecido ao buscar recursos de ajuda.');
    }
  }

  /// Aciona um alerta de comportamento de risco no backend (para fins de auditoria).
  Future<void> triggerAlert(String reason) async {
    try {
      // Atualiza o estado local (para feedback imediato da UI, se necessário)
      _model = _model?.copyWith(
        lastTriggeredAlert: reason,
        lastAlertTimestamp: DateTime.now(),
      );
      notifyListeners();
      
      // Envia o alerta para o serviço de infraestrutura
      await _alertsService.triggerAlert(reason);
      
    } on AlertsServiceException catch (e) {
      if (kDebugMode) {
        print('Falha ao registar alerta no serviço: $e');
      }
      // Opcional: Reverter o estado local se o serviço falhar
    }
  }
}