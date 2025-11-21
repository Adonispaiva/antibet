import 'dart:convert';
import 'package:antibet/core/errors/failures.dart';
import 'package:antibet/core/services/secure_storage_service.dart';
import 'package:antibet/features/auth/models/user_model.dart';
import 'package:antibet/features/auth/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'packagepackage:equatable/equatable.dart';

// 1. DEFINIÇÃO DO ESTADO (UserState)
// Usamos Equatable para facilitar a comparação de estados.

abstract class UserState extends Equatable {
  const UserState();
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserModel user;
  const UserLoaded({required this.user});
  @override
  List<Object?> get props => [user];
}

class UserLoggedOut extends UserState {}

class UserError extends UserState {
  final String message;
  const UserError({required this.message});
  @override
  List<Object?> get props => [message];
}

// 2. DEFINIÇÃO DO NOTIFIER (UserProvider)

class UserProvider extends StateNotifier<UserState> {
  UserProvider({
    required this.authService,
    required this.storageService,
  }) : super(UserInitial());

  final IAuthService authService;
  final ISecureStorageService storageService;

  /// Tenta carregar o usuário do storage local.
  /// Disparado pelo SplashScreen.
  Future<void> loadUser() async {
    state = UserLoading();
    try {
      final userString = await storageService.read(key: 'user');
      if (userString == null) {
        state = UserLoggedOut();
        return;
      }

      final user = UserModel.fromJson(jsonDecode(userString));

      // Valida o token do usuário com a API
      final validationResult = await authService.validateToken(user.token);

      validationResult.fold(
        (failure) {
          // Se a validação falhar (ex: API offline), desloga
          state = UserLoggedOut();
        },
        (isValid) {
          if (isValid) {
            state = UserLoaded(user: user);
          } else {
            // Se o token for inválido, desloga
            state = UserLoggedOut();
          }
        },
      );
    } catch (e) {
      // Se houver qualquer erro (ex: JSON mal formatado), desloga
      state = UserLoggedOut();
    }
  }

  /// Tenta realizar o login.
  Future<void> login(String email, String password) async {
    state = UserLoading();
    final result = await authService.login(email, password);

    result.fold(
      (failure) {
        state = UserError(message: failure.message);
      },
      (user) async {
        // Salva o usuário no storage antes de atualizar o estado
        await storageService.write(
            key: 'user', value: jsonEncode(user.toJson()));
        state = UserLoaded(user: user);
      },
    );
  }

  /// Tenta realizar o registro.
  Future<void> register({
    required String email,
    required String name,
    required String password,
  }) async {
    state = UserLoading();
    final result = await authService.register(
      email: email,
      name: name,
      password: password,
    );

    result.fold(
      (failure) {
        state = UserError(message: failure.message);
      },
      (user) async {
        // Salva o usuário no storage antes de atualizar o estado
        await storageService.write(
            key: 'user', value: jsonEncode(user.toJson()));
        state = UserLoaded(user: user);
      },
    );
  }

  /// Realiza o logout.
  Future<void> logout() async {
    state = UserLoading();
    // Limpa o storage local
    await storageService.delete(key: 'user');
    // TODO: Chamar authService.logout() se houver uma API de
    // invalidação de token no backend.
    state = UserLoggedOut();
  }
}

// 3. DEFINIÇÃO DO PROVIDER (userProvider)
// Este é o provider que a UI irá consumir.

final userProvider = StateNotifierProvider<UserProvider, UserState>((ref) {
  // Obtém as dependências (outros services)
  final authService = ref.watch(authServiceProvider);
  final storageService = ref.watch(secureStorageServiceProvider);

  return UserProvider(
    authService: authService,
    storageService: storageService,
  );
});