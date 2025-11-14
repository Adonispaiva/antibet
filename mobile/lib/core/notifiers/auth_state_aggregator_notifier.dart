import 'package:flutter/foundation.dart';
import 'package:antibet/core/notifiers/auth_notifier.dart';
import 'package:antibet/core/notifiers/user_profile_notifier.dart';

/// Notifier de alto nível (Aggregator) que combina o estado de vários notifiers
/// relacionados à autenticação e gerencia o processo de inicialização do aplicativo.
class AuthStateAggregatorNotifier extends ChangeNotifier {
  final AuthNotifier _authNotifier;
  final UserProfileNotifier _userProfileNotifier;

  // Estado de carregamento inicial (útil para Splash Screen).
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  AuthStateAggregatorNotifier(this._authNotifier, this._userProfileNotifier) {
    // Escuta mudanças no AuthNotifier para atualizar o estado automaticamente
    // quando o usuário faz login ou logout.
    _authNotifier.addListener(_onAuthChange);
  }

  void _onAuthChange() {
    // Se a autenticação mudar, o listener será notificado.
    // Nenhuma lógica extra é necessária aqui, apenas reage à mudança.
    notifyListeners();
  }

  // Define se o usuário está autenticado, delegando a responsabilidade
  // para o AuthNotifier.
  bool get isAuthenticated => _authNotifier.isLoggedIn;
  
  // Define o ID do usuário (ou '0' se não logado).
  String get currentUserId => _userProfileNotifier.profile.userId;

  /// Método chamado uma única vez no início do aplicativo (main.dart)
  /// para simular a checagem de sessão persistente e o carregamento de dados iniciais.
  Future<void> initialize() async {
    // 1. Simulação de checagem de token persistente (StorageService)
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Simulação: Se um token for encontrado (simulado como true)
    bool hasPersistedSession = false; // Mantenha como false para forçar a tela de Login inicialmente
    
    if (hasPersistedSession) {
      // Se houver sessão, simula a recuperação de dados
      // await _authNotifier.loadSession(); 
      // await _userProfileNotifier.loadProfile(_authNotifier.userToken!);
    }
    
    // 2. Finaliza o carregamento (fecha a tela de Splash/Loading)
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _authNotifier.removeListener(_onAuthChange);
    super.dispose();
  }
}