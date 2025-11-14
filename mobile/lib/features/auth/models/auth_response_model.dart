// mobile/lib/features/auth/models/auth_response_model.dart

import 'dart:convert';
import 'package:flutter/foundation.dart'; // Para debugPrint

/// Modelo de dados que representa a resposta bem-sucedida de Login ou Registro da API.
/// 
/// Contém o token de acesso (JWT) e o tipo, que são salvos localmente pelo AuthService.
class AuthResponseModel {
  final String accessToken;
  final String tokenType; // Ex: 'Bearer'

  const AuthResponseModel({
    required this.accessToken,
    required this.tokenType,
  });

  /// Constrói um AuthResponseModel a partir de um mapa JSON (Resposta da API).
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] as String,
      tokenType: json['tokenType'] as String,
    );
  }

  /// Converte o AuthResponseModel para um mapa JSON (Para salvar no Storage local).
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'tokenType': tokenType,
    };
  }
  
  /// Cria uma cópia imutável do AuthResponseModel com valores opcionais substituídos.
  AuthResponseModel copyWith({
    String? accessToken,
    String? tokenType,
  }) {
    return AuthResponseModel(
      accessToken: accessToken ?? this.accessToken,
      tokenType: tokenType ?? this.tokenType,
    );
  }

  // Sobrescrita do toString() para melhor debug
  @override
  String toString() {
    return 'AuthResponseModel(tokenType: $tokenType, accessToken: ${accessToken.substring(0, 10)}...)';
  }
}