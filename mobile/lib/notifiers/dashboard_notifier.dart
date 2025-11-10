import 'package:flutter/foundation.dart';

// Importações dos modelos e serviços
import '../core/domain/dashboard_content_model.dart'; 
import '../infra/services/dashboard_service.dart';
// Note: O AuthNotifier seria injetado aqui para verificar o estado de login, mas simplificaremos a dependência por enquanto.

/// Enum para representar os estados possíveis do Conteúdo do Dashboard.
enum DashboardState {
  initial, 
  loading,
  loaded,
  error
}

/// O Notifier de Dashboard gerencia o conteúdo principal da aplicação.
class DashboardNotifier with ChangeNotifier {
  final DashboardService _dashboardService;

  DashboardContentModel? _content;
  DashboardState _state = DashboardState.initial;
  String? _errorMessage;

  DashboardNotifier(this._dashboardService);

  // Getters Públicos
  DashboardContentModel? get content => _content;
  DashboardState get state => _state;
  String? get errorMessage => _errorMessage;

  void _setState(DashboardState newState) {
    _state = newState;
    _errorMessage = null; 
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = DashboardState.error;
    notifyListeners();
  }

  /// Busca o conteúdo agregado do Dashboard na infraestrutura.
  Future<void> fetchDashboardContent() async {
    _setState(DashboardState.loading);
    try {
      final fetchedContent = await _dashboardService.fetchDashboardContent();
      _content = fetchedContent;
      _setState(DashboardState.loaded);
    } on DashboardException catch (e) {
      _setError('Falha ao carregar o Dashboard: ${e.message}');
    } catch (e) {
      _setError('Erro desconhecido ao buscar o Dashboard.');
    }
  }

  // Futuros métodos de refresh, etc., seriam adicionados aqui
}