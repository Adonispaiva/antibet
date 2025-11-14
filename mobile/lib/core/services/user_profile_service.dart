import 'package:antibet/core/models/user_profile_model.dart';
import 'package:antibet/core/services/storage_service.dart';

class UserProfileService {
  final StorageService _storageService;
  static const String _profileKey = 'user_profile_data';

  UserProfileService(this._storageService);

  /// Carrega o perfil do usuário do armazenamento.
  /// Retorna o perfil inicial se não houver dados.
  UserProfileModel loadProfile() {
    final profile = _storageService.loadObject<UserProfileModel>(
      _profileKey,
      UserProfileModel.fromJson,
    );
    return profile ?? UserProfileModel.initial();
  }

  /// Salva as alterações no perfil do usuário.
  Future<bool> saveProfile(UserProfileModel profile) async {
    return await _storageService.saveObject<UserProfileModel>(
      _profileKey,
      profile,
      (p) => p.toJson(),
    );
  }
  
  /// Limpa os dados do perfil (usado no logout).
  Future<bool> clearProfile() async {
    return await _storageService.remove(_profileKey);
  }
}