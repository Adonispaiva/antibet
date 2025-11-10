import 'dart:async';
import 'dart:math';

// Importação do modelo de Domínio
import '../../core/domain/dashboard_content_model.dart';

/// Classe de exceção personalizada para falhas na operação de Dashboard.
class DashboardException implements Exception {
  final String message;
  DashboardException(this.message);

  @override
  String toString() => 'DashboardException: $message';
}

/// O serviço de Dashboard é responsável pela agregação de dados de múltiplos 
/// serviços de backend (simulados) para construir o conteúdo principal da tela.
class DashboardService {

  // Dependências futuras (ex: BalanceService, NotificationService) seriam injetadas aqui.

  DashboardService();

  /// Simula a busca e agregação do conteúdo do Dashboard na API.
  Future<DashboardContentModel> fetchDashboardContent() async {
    // Simulação de delay de rede para agregação de múltiplas chamadas
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // --- SIMULAÇÃO DE LÓGICA DE API (Agregação) ---
      
      // 1. Busca de métricas:
      final int analyzedCount = Random().nextInt(1000) + 500; 

      // 2. Busca de saldo:
      final double balance = (Random().nextDouble() * 10000).truncateToDouble() / 100;
      
      // 3. Busca de Alertas:
      final String alert = analyzedCount > 800 
          ? 'Análise de alta performance concluída.' 
          : 'Requer mais 50 análises para métricas precisas.';

      // Constrói o modelo de agregação
      final content = DashboardContentModel(
        totalBetsAnalyzed: analyzedCount,
        recentActivityTitle: alert,
        currentBalance: balance,
      );
      
      return content;
      
    } on Exception catch (e) {
      // Trata falhas de serviços de terceiros/infraestrutura
      throw DashboardException('Falha na agregação de dados para o Dashboard: $e');
    }
  }
}