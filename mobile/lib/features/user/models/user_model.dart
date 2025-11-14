// mobile/lib/features/user/models/user_model.dart

import 'dart:convert';
import 'package:flutter/foundation.dart'; // Para listEquals e debugPrint

/// Modelo de dados que representa o perfil do usuário no Mobile.
/// É a representação tipada do que é retornado pelo endpoint GET /user/profile.
class UserModel {
  final int id;
  final String email;
  final String? name;
  final bool isPremiumActive; // Usado pelo SubscriptionNotifier/Gating
  final String? currency; // Ex: BRL, USD

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    required this.isPremiumActive,
    this.currency,
  });

  /// Constrói um UserModel a partir de um mapa JSON (Resposta da API).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String?,
      isPremiumActive: json['isPremiumActive'] as bool? ?? false, // Garante que seja false se nulo
      currency: json['currency'] as String?,
    );
  }

  /// Converte o UserModel para um mapa JSON (Para salvar no Storage local pelo UserService).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'isPremiumActive': isPremiumActive,
      'currency': currency,
    };
  }
  
  /// Cria uma cópia imutável do UserModel com valores opcionais substituídos.
  UserModel copyWith({
    int? id,
    String? email,
    ValueGetter<String?>? name,
    bool? isPremiumActive,
    ValueGetter<String?>? currency,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      // ValueGetter é usado para permitir a passagem de null como valor de substituição
      name: name != null ? name() : this.name,
      isPremiumActive: isPremiumActive ?? this.isPremiumActive,
      currency: currency != null ? currency() : this.currency,
    );
  }

  // Omitindo a sobrecarga de hashCode e operator == por não serem cruciais para a persistência.
}