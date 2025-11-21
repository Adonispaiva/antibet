// mobile/lib/core/models/auth_response_model.dart

import 'package:antibet/core/models/user_model.dart'; // Assumindo o caminho correto para o UserModel

/// Modelo de dados para a resposta de login/registro da API.
/// Corresponde ao AuthResponseDto do Backend.
class AuthResponseModel {
  final String accessToken;
  final UserModel user;

  AuthResponseModel({
    required this.accessToken,
    required this.user,
  });

  /// Factory method para desserializar JSON em AuthResponseModel
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'] as String,
      // O campo user e desserializado em UserModel
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  /// Converte o modelo em JSON (para serializacao ou cache)
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'user': user.toJson(),
    };
  }
}