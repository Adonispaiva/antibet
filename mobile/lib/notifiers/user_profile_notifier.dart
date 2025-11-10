import 'package:flutter/foundation.dart';

// Importações dos modelos e serviços
import '../core/domain/user_profile_model.dart'; 
import '../core/domain/user_model.dart';
import '../infra/services/user_profile_service.dart';
import 'auth_notifier.dart'; // Para acessar o usuário logado

/// Enum para representar os estados possíveis do Perfil.
enum ProfileState {
  initial, 
  loading,
  loaded,
  error
}

/// O Notifier de Perfil gerencia o estado do UserProfileModel na aplicação.
class UserProfileNotifier with ChangeNotifier {
  final UserProfileService _profileService;
  final AuthNotifier _authNotifier; // Dependência para obter o usuário logado

  UserProfileModel? _userProfile;
  ProfileState _state = ProfileState.initial;
  String? _errorMessage;

  UserProfileNotifier(this._profileService, this._authNotifier) {
    // Escuta mudanças de autenticação para recarregar ou limpar o perfil
    _authNotifier.addListener(_handleAuthChange);
  }

  // Getters Públicos
  UserProfileModel? get userProfile => _userProfile;
  ProfileState get state => _state;
  String? get errorMessage => _errorMessage;

  void _setState(ProfileState newState) {
    _state = newState;
    _errorMessage = null; 
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = ProfileState.error;
    notifyListeners();
  }

  /// Limpa o perfil ao fazer logout.
  void _handleAuthChange() {
    if (!_authNotifier.isAuthenticated) {
      _userProfile = null;
      _setState(ProfileState.initial);
    } else {
       // Se o usuário logou, tenta buscar o perfil imediatamente (opcional)
       // fetchProfile();
    }
  }

  /// Busca o perfil do usuário na infraestrutura.
  Future<void> fetchProfile() async {
    final UserModel? user = _authNotifier.currentUser;
    if (user == null) {
      _setError('Usuário não logado. Impossível buscar perfil.');
      return;
    }
    
    _setState(ProfileState.loading);
    try {
      final profile = await _profileService.fetchProfile(user);
      _userProfile = profile;
      _setState(ProfileState.loaded);
    } on UserProfileException catch (e) {
      _setError('Falha ao carregar perfil: ${e.message}');
    } catch (e) {
      _setError('Erro desconhecido ao buscar perfil.');
    }
  }

  /// Atualiza o perfil do usuário na infraestrutura.
  Future<void> updateProfile({
    String? fullName,
    String? phoneNumber,
    DateTime? dateOfBirth,
  }) async {
    if (_userProfile == null) {
      _setError('Nenhum perfil carregado para atualização.');
      return;
    }

    _setState(ProfileState.loading);
    try {
      // Cria uma nova instância imutável com os dados atualizados
      final updatedProfile = _userProfile!.copyWith(
        fullName: fullName,
        phoneNumber: phoneNumber != null ? () => phoneNumber : null,
        dateOfBirth: dateOfBirth != null ? () => dateOfBirth : null,
      );

      final result = await _profileService.updateProfile(updatedProfile);
      _userProfile = result;
      _setState(ProfileState.loaded);
    } on UserProfileException catch (e) {
      _setError('Falha ao atualizar perfil: ${e.message}');
      // Mantém o estado anterior de loaded (se houver) ou inicial
      _state = _userProfile != null ? ProfileState.loaded : ProfileState.initial; 
      notifyListeners();
      rethrow; // Relança para a UI poder exibir um feedback específico
    } catch (e) {
      _setError('Erro desconhecido ao atualizar perfil.');
      _state = _userProfile != null ? ProfileState.loaded : ProfileState.initial;
      notifyListeners();
      rethrow;
    }
  }
  
  // É crucial remover o listener para evitar memory leaks
  @override
  void dispose() {
    _authNotifier.removeListener(_handleAuthChange);
    super.dispose();
  }
}