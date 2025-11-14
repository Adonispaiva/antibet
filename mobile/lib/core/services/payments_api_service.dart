// mobile/lib/core/services/payments_api_service.dart

import 'dart:convert';
import 'package:antibet/core/services/auth_service.dart';
import 'package:antibet/features/payments/models/subscription_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:antibet/config/app_config.dart'; // Importação do AppConfig

// const String _kApiUrl = 'http://localhost:3000/api/payments'; // Removido!

class PaymentsApiService {
  final AuthService _authService;

  PaymentsApiService(this._authService);

  /// Helper para construir os headers com o Token JWT.
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Autenticação necessária para acessar Pagamentos.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Injeção do token JWT
    };
  }

  /// Inicia uma sessão de checkout no Backend (POST) e retorna a URL de redirecionamento.
  /// @param planId O ID do plano selecionado.
  /// @returns A URL do gateway de pagamento.
  Future<String> createCheckoutSession(int planId) async {
    final url = Uri.parse('${AppConfig.apiUrl}/payments/checkout'); // Usando AppConfig

    // Usando AppConfig para as URLs de redirecionamento
    const successUrl = AppConfig.paymentSuccessUrl;
    const cancelUrl = AppConfig.paymentCancelUrl;
    
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({
          'planId': planId,
          'successUrl': successUrl,
          'cancelUrl': cancelUrl,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final redirectUrl = data['url'];
        
        if (redirectUrl != null) {
          debugPrint('PaymentsApiService: Sessão de Checkout criada. URL: $redirectUrl');
          return redirectUrl;
        }
      }
      
      debugPrint('PaymentsApiService: Falha ao criar sessão. Status: ${response.statusCode}');
      throw Exception('Falha ao iniciar o fluxo de checkout.');
    } catch (e) {
      debugPrint('PaymentsApiService: Erro de conexão ao criar sessão: $e');
      rethrow;
    }
  }

  /// Consulta o status de assinatura do usuário logado (GET).
  /// @returns O modelo de assinatura.
  Future<SubscriptionModel> getSubscriptionStatus() async {
    final url = Uri.parse('${AppConfig.apiUrl}/payments/status'); // Usando AppConfig
    
    try {
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('PaymentsApiService: Status de assinatura obtido.');
        return SubscriptionModel.fromJson(data);
      }
      
      debugPrint('PaymentsApiService: Falha ao obter status. Status: ${response.statusCode}');
      // Em caso de 404 (sem assinatura), o Backend deve retornar um status claro (ex: is_active=false)
      throw Exception('Falha ao obter status de assinatura.');
    } catch (e) {
      debugPrint('PaymentsApiService: Erro de conexão ao obter status: $e');
      rethrow;
    }
  }
}