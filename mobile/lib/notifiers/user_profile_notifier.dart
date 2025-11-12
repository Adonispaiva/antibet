import 'package:antibet_mobile/infra/services/user_profile_service.dart';
import 'package:antibet_mobile/models/user_model.dart';
import 'package:antibet_mobile/notifiers/auth_notifier.dart';
import 'package:flutter/material.dart';

/// Gerencia o estado do perfil do usuário (dados detalhados).
///
/// Este Notifier depende do [AuthNotifier] para obter o usuário
/// autenticado inicial e usa [UserProfileService] para atualizar
/// os dados do perfil no backend.
class UserProfileNotifier with ChangeNotifier {
  final UserProfileService _profileService;
  final AuthNotifier _authNotifier; // Dependência para sincronia

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Construtor com injeção de dependência
  UserProfileNotifier(this._profileService, this._authNotifier) {
    // Sincroniza o usuário do AuthNotifier
    _user = _authNotifier.user;
  }

  // Getters públicos
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Atualiza o [UserModel] interno com base no [AuthNotifier].
  /// Este método é chamado pelo ChangeNotifierProxyProvider no main.dart.
  void updateUserFromAuth(AuthNotifier authNotifier) {
    if (_user != authNotifier.user) {
      _user = authNotifier.user;
      
      // Se o usuário mudou (ex: login/logout), limpa estados de erro/loading
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Carrega (ou recarrega) os dados do perfil do serviço.
  /// Útil se o perfil tiver mais dados que o objeto de login.
  Future<void> fetchProfile() async {
    _setStateLoading(true);
    try {
      final updatedUser = await _profileService.getUserProfile();
      _user = updatedUser;
      
      // Opcional: Notificar o AuthNotifier se o objeto dele estiver defasado
      // (Depende da regra de negócio)

    } catch (e) {
      debugPrint('[UserProfileNotifier] Erro ao buscar perfil: $e');
      _errorMessage = 'Falha ao buscar dados do perfil.';
    } finally {
      _setStateLoading(false);
    }
  }

  /// Tenta atualizar o perfil do usuário no backend.
  Future<bool> updateProfile(UserModel userToUpdate) async {
    _setStateLoading(true);
    try {
      final updatedUser = await _profileService.updateUserProfile(userToUpdate);
      _user = updatedUser;
      
      // Opcional: Sincronizar com AuthNotifier (se necessário)

      _setStateLoading(false);
      return true;
    } catch (e) {
      debugPrint('[UserProfileNotifier] Erro ao atualizar perfil: $e');
      _errorMessage = 'Falha ao salvar dados.';
      _setStateLoading(false);
      return false;
    }
  }

  /// Helper interno para gerenciar o estado e notificar ouvintes.
  void _setStateLoading(bool loading) {
    _isLoading = loading;
    _errorMessage = null; // Limpa erros ao iniciar nova ação
    notifyListeners();
  }
}