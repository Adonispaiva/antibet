import 'package:flutter/material.dart';
import 'package:mobile/infra/services/auth_service.dart'; // Para UserModel
import 'package:mobile/infra/services/user_profile_service.dart';
import 'package:mobile/notifiers/auth_notifier.dart';

// O UserProfileNotifier gerencia o estado e os dados do perfil do usuário
// e reage às mudanças de autenticação.
class UserProfileNotifier extends ChangeNotifier {
  final UserProfileService _profileService;
  final AuthNotifier _authNotifier;

  // Variáveis de Estado
  UserModel? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  // Construtor com injeção de dependência e listener para o AuthNotifier
  UserProfileNotifier(
    this._profileService,
    this._authNotifier,
  ) {
    // Adiciona o listener para reagir a mudanças no AuthNotifier (login/logout)
    _authNotifier.addListener(_onAuthChange);
  }

  // Getters para acessar o estado
  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Define o estado de carregamento
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Define a mensagem de erro
  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Lógica para reagir a mudanças de autenticação
  void _onAuthChange() {
    if (_authNotifier.isAuthenticated && _userProfile == null) {
      // Se o usuário acabou de logar e não tem perfil carregado, carrega o perfil.
      fetchProfile();
    } else if (!_authNotifier.isAuthenticated) {
      // Se o usuário fez logout, limpa o perfil.
      _userProfile = null;
      _setErrorMessage(null);
      notifyListeners();
    }
  }

  // 1. Busca os dados do perfil do usuário
  Future<void> fetchProfile() async {
    if (_isLoading || !_authNotifier.isAuthenticated) return;

    _setLoading(true);
    _setErrorMessage(null);

    try {
      final profile = await _profileService.fetchUserProfile();
      _userProfile = profile;
    } catch (e) {
      _setErrorMessage('Não foi possível carregar o perfil do usuário.');
      _userProfile = null;
    } finally {
      _setLoading(false);
    }
  }

  // 2. Atualiza os dados do perfil do usuário
  Future<bool> updateProfile({
    required String name,
    required String email,
    // Outros campos...
  }) async {
    _setLoading(true);
    _setErrorMessage(null);
    bool success = false;

    try {
      final updatedProfile = await _profileService.updateUserProfile(
        name: name,
        email: email,
      );

      if (updatedProfile != null) {
        _userProfile = updatedProfile;
        success = true;
      } else {
        _setErrorMessage('Falha ao atualizar o perfil. Tente novamente.');
      }
    } catch (e) {
      _setErrorMessage('Erro de conexão ao atualizar o perfil.');
    } finally {
      _setLoading(false);
    }
    return success;
  }

  @override
  void dispose() {
    // Remove o listener para evitar memory leaks
    _authNotifier.removeListener(_onAuthChange);
    super.dispose();
  }
}