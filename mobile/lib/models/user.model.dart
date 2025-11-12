/// Representa o modelo de dados de um Usuário no sistema AntiBet.
///
/// Esta classe é usada para deserializar (fromJson) os dados vindos da API
/// e serializar (toJson) dados para enviar ao backend.
class UserModel {
  final String id;
  final String email;
  final String? name; // O nome pode ser opcional dependendo do fluxo de registro
  final DateTime? createdAt;
  // Outros campos relevantes (ex: subscriptionStatus, avatarUrl) podem ser adicionados aqui.

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.createdAt,
  });

  /// Construtor de fábrica para criar uma instância de [UserModel] a partir de um Map (JSON).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  /// Converte a instância de [UserModel] em um Map (JSON).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Cria uma cópia do [UserModel] com campos atualizados (imutabilidade).
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name)';
  }
}