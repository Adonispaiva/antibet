import 'package:flutter/material.dart';
import 'package:antibet_mobile/infra/services/bet_strategy_service.dart';
import 'package:antibet_mobile/models/strategy_model.dart';

/// Gerencia o estado relacionado às estratégias de apostas (Bet Strategies).
///
/// Este Notifier utiliza o [BetStrategyService] para buscar e manipular
/// os dados das estratégias, expondo-os para a UI através do Provider.
class BetStrategyNotifier with ChangeNotifier {
  final BetStrategyService _betStrategyService;

  bool _isLoading = false;
  List<StrategyModel> _strategies = []; // AGORA TIPADO
  String? _errorMessage;

  // Construtor com injeção de dependência obrigatória.
  BetStrategyNotifier(this._betStrategyService);

  // Getters públicos para expor o estado (read-only).
  bool get isLoading => _isLoading;
  List<StrategyModel> get strategies => List.unmodifiable(_strategies); // AGORA TIPADO
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Carrega a lista de estratégias do serviço.
  Future<void> loadStrategies() async {
    _setStateLoading(true);
    _errorMessage = null; // Limpa erros anteriores

    try {
      // Chama o serviço (que agora retorna Future<List<StrategyModel>>)
      _strategies = await _betStrategyService.fetchStrategies();
      
      if (_strategies.isEmpty) {
        // Opcional: Tratar caso de lista vazia como uma mensagem
        _errorMessage = 'Nenhuma estratégia encontrada no momento.';
      }

    } catch (e) {
      // TODO: Implementar logging de erro robusto.
      debugPrint('[BetStrategyNotifier] Erro ao carregar estratégias: $e');
      _errorMessage = 'Falha ao buscar estratégias. Tente novamente.';
      _strategies = [];
    } finally {
      _setStateLoading(false);
    }
  }

  // --- Métodos de controle de estado ---

  /// Controla o estado de carregamento e notifica os ouvintes.
  void _setStateLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    } else {
      // Se o estado de loading não mudou, mas outros dados sim (erro, lista),
      // notifica mesmo assim.
      notifyListeners();
    }
  }

  // Outros métodos (ex: addStrategy, updateStrategy) serão implementados
  // conforme a necessidade do escopo do aplicativo.
}