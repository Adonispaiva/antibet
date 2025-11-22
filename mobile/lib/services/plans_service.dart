import 'package:dio/dio.dart';
import 'package:antibet_mobileapp/services/api_service.dart';

class PlansService {
  final Dio _dio = ApiService.instance;
  static const String _plansEndpoint = '/plans'; 

  // ... [fetchPlans method - Mantido] ...
  
  /// Chama o Backend para iniciar uma sessão de checkout no Stripe.
  /// @param planId ID do plano a ser comprado.
  /// @returns URL de redirecionamento para o Stripe.
  Future<String> initiateCheckout(String planId) async {
    try {
      final response = await _dio.post(
        '$_plansEndpoint/checkout',
        data: {
          'planId': planId,
        },
      );
      
      // O Backend deve retornar { checkoutUrl: '...' }
      final checkoutUrl = response.data['checkoutUrl'] as String;
      if (checkoutUrl.isEmpty) {
        throw Exception('O Backend não retornou uma URL de checkout válida.');
      }
      return checkoutUrl;

    } on DioException catch (e) {
      // Tratar erros de autenticação (401) ou plano não encontrado (404)
      final errorMessage = e.response?.data?['message'] ?? 'Falha ao iniciar checkout.';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Ocorreu um erro desconhecido ao iniciar o checkout: $e');
    }
  }

  // Futuramente: handleStripePaymentSuccess(url)
}