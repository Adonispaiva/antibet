import 'package:flutter/material.dart';

@immutable
class UserProfileModel {
  final String id;
  final String name;
  final String email;
  final DateTime memberSince;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.memberSince,
  });

  // Construtor padrão para o estado inicial/vazio
  factory UserProfileModel.initial() {
    return UserProfileModel(
      id: '',
      name: 'Guest User',
      email: '',
      memberSince: DateTime.now(),
    );
  }

  // Método auxiliar para criar uma cópia
  UserProfileModel copyWith({
    String? name,
    String? email,
  }) {
    return UserProfileModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      memberSince: memberSince,
    );
  }

  // Método auxiliar para criar o modelo a partir de JSON (desserialização)
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      memberSince: DateTime.parse(json['memberSince'] as String),
    );
  }

  // Método auxiliar para converter o modelo para JSON (serialização)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'memberSince': memberSince.toIso8601String(),
    };
  }
}