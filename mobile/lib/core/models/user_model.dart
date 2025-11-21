// mobile/lib/core/models/user_model.dart

/// Enum que representa o papel do usuário (role) no Backend.
enum UserRole {
  admin,
  premium,
  basic,
}

/// Modelo de dados para a Entidade Usuário.
/// Corresponde à resposta simplificada do Backend (sem a senha).
class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final bool isActive;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.isActive,
  });

  /// Factory method para desserializar JSON em UserModel.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Funcao auxiliar para mapear a string do backend para o Enum do Dart
    UserRole mapRole(String roleString) {
      switch (roleString) {
        case 'admin':
          return UserRole.admin;
        case 'premium':
          return UserRole.premium;
        default:
          return UserRole.basic;
      }
    }

    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      role: mapRole(json['role'] as String),
      isActive: json['isActive'] as bool,
    );
  }

  /// Converte o modelo em JSON (útil para cache local)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.toString().split('.').last, // Converte Enum para String
      'isActive': isActive,
    };
  }
}