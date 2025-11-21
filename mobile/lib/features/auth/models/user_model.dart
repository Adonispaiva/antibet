import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel {
  final String id;
  final String name;
  final String email;
  final String token; // Token de autenticação (JWT)

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // Método de conveniência para criar um usuário sem token (útil para modelos de dados puros, 
  // embora o token seja crucial para a sessão, mantemos o campo final)
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
    );
  }
  
  // Método de conveniência para verificar se o usuário está autenticado
  bool get isAuthenticated => token.isNotEmpty;
}