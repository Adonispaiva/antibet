// lib/core/models/user_model.dart

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String token; // Token de autenticação (JWT, etc.)
  final DateTime createdAt;

  // Construtor constante para garantir imutabilidade
  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.token,
    required this.createdAt,
  });

  // Método de fábrica para criar um UserModel a partir de um Map (JSON de API)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      token: json['token'] as String,
      // Converte o timestamp ou string de data para DateTime
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Método para converter o UserModel em um Map (JSON para API ou persistência)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'token': token,
      'createdAt': createdAt.toIso8601String(), // Formato padrão ISO
    };
  }

  // Método de cópia (copy with) para criar uma nova instância com valores atualizados
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? token,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}