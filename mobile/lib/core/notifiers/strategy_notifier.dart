import 'package:flutter/foundation.dart';
import 'package:antibet/core/models/strategy_model.dart'; // Importação do Modelo correto

/// Notifier responsável por gerenciar o estado da lista de estratégias de trading
/// configuradas ou utilizadas pelo usuário.
class StrategyNotifier extends ChangeNotifier {
  // Lista privada mutável que armazena as estratégias (Refatorado para StrategyModel).
  List<StrategyModel> _strategies = [];

  // Getter público para acessar a lista de estratégias.
  List<StrategyModel> get strategies => List.unmodifiable(_strategies);
  
  // Propriedade de exemplo para saber quantas estratégias estão ativas.
  int get activeStrategyCount => _strategies.length;

  /// Carrega as estratégias disponíveis para o usuário.
  /// No futuro, esta função irá buscar as estratégias no StrategyService.
  Future<void> loadStrategies() async {
    // Simulação de delay para operação de carregamento
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulação de dados de estratégias (Refatorado para StrategyModel)
    _strategies = [
      StrategyModel(
        id: '1', 
        name: 'Martingale Conservadora', 
        type: 'M', 
        winRate: 0.65
      ),
      StrategyModel(
        id: '2', 
        name: 'Fibonacci Agressiva', 
        type: 'F', 
        winRate: 0.58
      ),
      StrategyModel(
        id: '3', 
        name: 'Gestão de Banca Fixa', 
        type: 'G', 
        winRate: 0.70
      ),
    ];

    // Notifica a UI sobre as estratégias carregadas.
    notifyListeners();
  }

  // Futuramente, serão adicionados métodos para:
  // - addStrategy(): Adicionar uma nova estratégia.
  // - updateStrategy(): Modificar uma estratégia existente.
}