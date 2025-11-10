import 'dart:async';
import 'package:flutter/foundation.dart';

// Importação do modelo de Domínio
import '../../core/domain/help_and_alerts_model.dart';

/// Classe de exceção personalizada para falhas no serviço de Alertas e Ajuda.
class AlertsServiceException implements Exception {
  final String message;
  AlertsServiceException(this.message);

  @override
  String toString() => 'AlertsServiceException: $message';
}

/// O serviço de Alertas e Ajuda é responsável por fornecer recursos de apoio
/// e registrar eventos de comportamento de risco do usuário (missão Anti-Vício).
class HelpAndAlertsService {
  
  // Lista de recursos fixos (Simulação de dados de API)
  final List<HelpResourceModel> _mockResources = const [
    HelpResourceModel(
      title: 'Apoio Emocional - CVV',
      url: 'https://www.cvv.org.br',
      type: 'website',
    ),
    HelpResourceModel(
      title: 'Jogadores Anônimos',
      url: 'https://jogadoresanonimos.org.br',
      type: 'website',
    ),
    HelpResourceModel(
      title: 'Linha de Ajuda (Telefone)',
      url: '188', // Simulação de telefone de apoio
      type: 'phone',
    ),
  ];

  HelpAndAlertsService();

  /// Busca os recursos de ajuda e o status do último alerta.
  Future<HelpAndAlertsModel> fetchResources() async {
    // Simulação de delay de rede
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Simula a construção do modelo a partir da API
    final model = HelpAndAlertsModel(
      supportResources: _mockResources,
      lastTriggeredAlert: null, // Limpo por padrão
      lastAlertTimestamp: null,
    );
    
    return model;
  }

  /// Registra um evento de alerta de comportamento de risco (ex: tentou desativar regras).
  /// Esta é uma função de auditoria crucial para a reeducação.
  Future<void> triggerAlert(String reason) async {
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Simulação: Aqui o alerta seria enviado para o backend para fins de registro/auditoria.
    if (kDebugMode) {
      print('ALERTA ACIONADO: Razão: $reason em ${DateTime.now()}');
    }
  }
}