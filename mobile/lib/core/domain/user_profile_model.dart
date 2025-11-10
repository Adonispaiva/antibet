import 'package:flutter/foundation.dart';

/// Entidade de Domínio que representa o Perfil detalhado de um usuário.
/// Esta entidade reside na camada Core e é agnóstica a frameworks.
@immutable
class UserProfileModel {
  // Identificador do Perfil (muitas vezes é o mesmo ID do UserModel)
  final String userId; 
  final String fullName;
  final String? phoneNumber;
  final DateTime? dateOfBirth;

  const UserProfileModel({
    required this.userId,
    required this.fullName,
    this.phoneNumber,
    this.dateOfBirth,
  });

  /// Construtor de fábrica para desserialização JSON (API/Storage)
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth'] as String) 
          : null,
    );
  }

  /// Método para serialização JSON (Envio para API/Storage)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
    };
  }

  /// Cria uma cópia da entidade, opcionalmente com novos valores (imutabilidade)
  UserProfileModel copyWith({
    String? userId,
    String? fullName,
    ValueGetter<String?>? phoneNumber,
    ValueGetter<DateTime?>? dateOfBirth,
  }) {
    return UserProfileModel(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber != null ? phoneNumber() : this.phoneNumber,
      dateOfBirth: dateOfBirth != null ? dateOfBirth() : this.dateOfBirth,
    );
  }

  // Sobrescreve hashCode e equals para garantir comparabilidade no Core
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserProfileModel &&
      other.userId == userId &&
      other.fullName == fullName &&
      other.phoneNumber == phoneNumber &&
      other.dateOfBirth == dateOfBirth;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
      fullName.hashCode ^
      phoneNumber.hashCode ^
      dateOfBirth.hashCode;
  }
}