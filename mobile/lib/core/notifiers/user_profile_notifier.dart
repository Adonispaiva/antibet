import 'package:flutter/foundation.dart';
import 'package:antibet/core/models/user_profile_model.dart'; // Pressupondo que o caminho é este

/// Notifier responsável por gerenciar o estado e as informações do perfil
/// do usuário (nome, foto, e-mail, etc.).
class UserProfileNotifier extends ChangeNotifier {
  // Estado privado do perfil. Inicializa com um modelo básico.
  UserProfileModel _profile = UserProfileModel(
    userId: '0',
    name: 'Convidado',
    email: '',
    registrationDate: DateTime.now(),
  );

  // Getter público para acesso imutável às informações do perfil.
  UserProfileModel get profile => _profile;

  /// Carrega as informações do perfil do usuário (ex: após login).
  /// No futuro, usará o AuthService e StorageService.
  Future<void> loadProfile(String userId) async {
    // Simulação de delay para operação de carregamento
    await Future.delayed(const Duration(milliseconds: 700));

    // Simulação de dados carregados
    _profile = UserProfileModel(
      userId: userId,
      name: 'Adonis Paiva',
      email: 'adonis@inovexa.com',
      registrationDate: DateTime.utc(2025, 11, 01),
    );

    notifyListeners();
  }

  /// Atualiza o nome de exibição do usuário.
  Future<void> updateName(String newName) async {
    // Simulação de delay para operação de persistência (StorageService).
    await Future.delayed(const Duration(milliseconds: 400));
    
    // Cria um novo estado com o nome atualizado.
    _profile = _profile.copyWith(name: newName);

    notifyListeners();
  }

  // Futuramente, serão adicionados métodos para:
  // - updateEmail()
  // - updatePassword()
  // - updateProfilePicture()
}