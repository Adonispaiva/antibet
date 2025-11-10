/// Modelo de Dados do Usuário (UserModel)
///
/// Estrutura de dados imutável para representar um usuário autenticado.
/// Localizado na pasta `models` para garantir a separação de responsabilidades.
class UserModel {
  final String id;
  final String email;
  // Adicionar outros dados de usuário (nome, foto, escore de risco, etc.)
  // que são relevantes para a interface e o sistema.
  const UserModel({required this.id, required this.email});
  
  // Método opcional para facilitar a visualização em logs
  @override
  String toString() {
    return 'UserModel(id: $id, email: $email)';
  }

  // Método opcional para criar uma cópia modificada
  UserModel copyWith({
    String? id,
    String? email,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
    );
  }
}