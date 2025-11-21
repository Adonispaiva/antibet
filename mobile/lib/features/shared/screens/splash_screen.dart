import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:antibet/features/user/providers/user_provider.dart';
import 'package:antibet/core/routing/app_router.dart';

// O decorator @RoutePage() é exigido pelo auto_route para gerar a rota correspondente.
@RoutePage() 
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Acessamos as dependências registradas no GetIt (Injeção de Dependência)
  final UserProvider _userProvider = GetIt.I<UserProvider>();
  final AppRouter _router = GetIt.I<AppRouter>();

  @override
  void initState() {
    super.initState();
    // Chamamos a lógica de checagem após a construção inicial do widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  /// Verifica o status de autenticação e redireciona o usuário.
  Future<void> _checkAuthStatus() async {
    // 1. Tenta carregar o estado do usuário (validando token persistido)
    await _userProvider.initializeUser();

    // 2. Navegação condicional baseada no estado do provedor
    if (_userProvider.isLoggedIn) {
      // Rota para a shell principal (dashboard, navegação com tabs)
      await _router.replaceAll([const MainShellScreenRoute()]);
    } else {
      // Rota para a tela de Login
      await _router.replaceAll([const LoginScreenRoute()]);
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI Simples da Splash Screen (Exibindo logo ou indicador de loading)
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_soccer, size: 80, color: Color(0xFF1E88E5)), // Placeholder Azul
            SizedBox(height: 24),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Inovexa Software - AntiBet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}