import 'package:flutter/material.dart';
import 'package:antibet/src/core/services/user_profile_service.dart';
import 'package:antibet/src/core/notifiers/auth_notifier.dart'; // Dependência

// O Notifier gerencia o estado reativo dos dados do perfil do usuário

class UserProfileNotifier extends ChangeNotifier {
  final UserProfileService _service;
  final AuthNotifier _authNotifier; // Dependência do AuthNotifier
  
  // Variável privada para o estado do perfil
  UserProfile _profile = UserProfile();

  UserProfileNotifier(this._service, this._authNotifier) {
    // Escuta mudanças no estado de autenticação (login/logout)
    _authNotifier.addListener(_onAuthStatusChanged);
    
    // Tenta carregar o perfil inicial
    _onAuthStatusChanged();
  }

  // Getter público para consumo pela UI
  UserProfile get profile => _profile;
  
  // Getters de conveniência para personalização da IA
  String get nickname => _profile.nickname ?? 'Usuário(a)';
  String get gender => _profile.gender ?? 'Não Informado';
  
  // Calcula idade aproximada (simulação)
  int get age {
    final birthYearString = _profile.birthYearMonth;
    if (birthYearString != null && birthYearString.length >= 4) {
      final birthYear = int.tryParse(birthYearString.substring(0, 4));
      if (birthYear != null) {
        return DateTime.now().year - birthYear;
      }
    }
    return 0; // Desconhecida ou padrão
  }


  // Lógica de carregamento condicional baseada no status de autenticação
  void _onAuthStatusChanged() {
    if (_authNotifier.isLoggedIn) {
      loadUserProfile();
    } else {
      // Limpa o perfil ao fazer logout
      _profile = UserProfile();
      notifyListeners();
    }
  }

  /// Carrega o perfil do serviço e atualiza o estado
  Future<void> loadUserProfile() async {
    _profile = await _service.loadProfile();
    notifyListeners();
    print('Perfil de usuário carregado: ${nickname}, Idade: ${age}');
  }

  /// Atualiza o perfil no Service e no Notifier (usado no Cadastro Inicial)
  Future<void> updateProfile(UserProfile newProfile) async {
    // 1. Salva no Service (persiste)
    await _service.saveProfile(newProfile);
    
    // 2. Atualiza o estado local
    _profile = newProfile;
    
    // 3. Notifica a UI
    notifyListeners();
    print('Perfil atualizado. Nível de preocupação: ${_profile.concernLevel}');
  }
  
  @override
  void dispose() {
    _authNotifier.removeListener(_onAuthStatusChanged);
    super.dispose();
  }
}