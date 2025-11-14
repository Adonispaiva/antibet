// mobile/lib/core/services/plans_service.dart

import 'dart:convert';
import 'package:antibet/core/services/auth_service.dart';
import 'package:antibet/features/plans/models/plan_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:antibet/config/app_config.dart'; // Importação do AppConfig

// const String _kApiUrl = 'http://localhost:3000/api/plans'; // Removido!

class PlansService {
  final AuthService _authService;

  PlansService(this._authService);

  /// Helper para construir os headers com o Token JWT.
  /// Embora planos possam ser públicos, usamos o token para consistência arquitetural.
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    if (token == null) {
      // Se não houver token (usuário anônimo), enviamos apenas o Content-Type
      return {'Content-Type': 'application/json'};
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Injeção do token JWT
    };
  }

  /// Obtém a lista de planos de assinatura do Backend (GET).
  Future<List<PlanModel>> loadPlans() async {
    final url = Uri.parse('${AppConfig.apiUrl}/plans'); // Usando AppConfig
    
    try {
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        debugPrint('PlansService: Lista de planos obtida.');
        return data.map((item) => PlanModel.fromJson(item)).toList();
      }
      
      debugPrint('PlansService: Falha ao carregar planos. Status: ${response.statusCode}');
      throw Exception('Falha ao carregar lista de planos de assinatura.');
    } catch (e) {
      debugPrint('PlansService: Erro de conexão ao carregar planos: $e');
      rethrow;
    }
  }
}