import 'package:flutter/material.dart';
import 'package:antibet_mobileapp/services/auth_service.dart';
import 'package:antibet_mobileapp/core/routing/app_routes.dart';

class RegisterController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Tenta registrar o usuário e navega para o Dashboard em caso de sucesso.
  Future<void> register(String email, String password, String firstName, BuildContext context) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Chama o serviço para registro (e salva o token)
      await _authService.registerUser(email, password, firstName);

      // 2. Navegação em caso de sucesso
      if (context.mounted) {
        // Redirecionar para a Dashboard (Autenticado)
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }

    } catch (e) {
      // 3. Trata e exibe o erro
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Limpa o erro ao digitar
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}