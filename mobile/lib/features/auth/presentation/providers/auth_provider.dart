import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antibet/core/local_storage/storage_service.dart';

/// Estado de autenticação contendo o token JWT e status de carregamento.
class AuthState {
  final String? token;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.token,
    this.isLoading = false,
    this.error,
  });

  /// Verifica se o usuário está autenticado baseando-se na presença do token.
  bool get isAuthenticated => token != null && token!.isNotEmpty;

  AuthState copyWith({
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Notifier para gerenciar o estado de autenticação com persistência.
class AuthNotifier extends StateNotifier<AuthState> {
  final StorageService _storage;

  AuthNotifier(this._storage) : super(const AuthState()) {
    _init();
  }

  /// Tenta recuperar o token armazenado ao inicializar.
  void _init() {
    final storedToken = _storage.getString('auth_token');
    if (storedToken != null && storedToken.isNotEmpty) {
      state = state.copyWith(token: storedToken);
    }
  }

  /// Define o token de autenticação após um login bem-sucedido e o persiste.
  Future<void> setToken(String token) async {
    await _storage.setString('auth_token', token);
    state = state.copyWith(token: token, error: null, isLoading: false);
  }

  /// Inicia o estado de carregamento.
  void setLoading() {
    state = state.copyWith(isLoading: true, error: null);
  }

  /// Define uma mensagem de erro e remove o loading.
  void setError(String message) {
    state = state.copyWith(error: message, isLoading: false);
  }

  /// Realiza o logout limpando o estado e removendo o token do armazenamento.
  Future<void> logout() async {
    await _storage.remove('auth_token');
    state = const AuthState();
  }
}

/// Provider global de autenticação.
/// Depende do storageServiceProvider para persistência.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return AuthNotifier(storage);
});