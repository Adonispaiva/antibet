import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antibet/features/auth/models/user_model.dart';
import 'package:antibet/features/auth/services/auth_service.dart';
import 'package:antibet/features/journal/providers/journal_provider.dart'; // Para invalidar dados do journal no logout

// 1. Definição do AuthService Provider (injeção de dependência)
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// 2. Definição do Auth Provider
// Expõe o estado do usuário (logado ou não) de forma assíncrona.
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  final service = ref.watch(authServiceProvider);
  return AuthNotifier(ref, service);
});


// 3. O Notifier que contém a lógica de estado e as chamadas de serviço
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final Ref _ref;
  final AuthService _service;

  AuthNotifier(this._ref, this._service) : super(const AsyncValue.loading()) {
    // Tenta carregar a sessão na inicialização (auto-login)
    _attemptAutoLogin();
  }

  /// ----------------------------------------------------
  /// FLUXO: CARREGAMENTO INICIAL / AUTO-LOGIN
  /// ----------------------------------------------------
  Future<void> _attemptAutoLogin() async {
    try {
      final token = await _service.getToken();
      if (token != null && token.isNotEmpty) {
        // Se o token existe, assume-se que o usuário está logado (validar o token no backend seria mais seguro)
        // A API real deve ter um endpoint /auth/me ou /auth/refresh para validar o token.
        // Por enquanto, criamos um modelo básico para simular a sessão ativa.
        final user = UserModel(id: '0', name: 'User', email: 'user@session.com', token: token);
        state = AsyncValue.data(user);
      } else {
        // Nenhum token encontrado
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      // Falha ao tentar ler o storage (tratada como sessão inexistente)
      state = AsyncValue.error('Falha na inicialização da sessão.', st);
    }
  }


  /// ----------------------------------------------------
  /// FLUXO: LOGIN
  /// ----------------------------------------------------
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _service.login(email, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error('Credenciais inválidas ou erro de rede.', st);
      // Re-lança o erro para a UI de login tratar o feedback específico
      throw Exception('Login falhou.');
    }
  }

  /// ----------------------------------------------------
  /// FLUXO: LOGOUT
  /// ----------------------------------------------------
  Future<void> logout() async {
    // Define o estado para loading enquanto o processo ocorre
    state = const AsyncValue.loading(); 
    try {
      await _service.logout();
      
      // Invalida o provider de Journal para garantir que dados sensíveis sejam limpos
      _ref.invalidate(journalProvider);

      // Define o estado como deslogado
      state = const AsyncValue.data(null);
    } catch (e) {
      // Se o logout na API falhar, o token local já foi limpo no `AuthService`, o que é o mais importante.
      state = const AsyncValue.data(null); 
    }
  }
}