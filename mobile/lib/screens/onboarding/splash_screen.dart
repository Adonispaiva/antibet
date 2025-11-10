import 'package:flutter/material.dart';
import 'package:antibet_mobileapp/core/routing/app_routes.dart';
import 'package:antibet_mobileapp/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService(); // O serviço foi inicializado no main.dart

  @override
  void initState() {
    super.initState();
    _checkRoutingDecision();
  }

  Future<void> _checkRoutingDecision() async {
    // Simular um atraso de carregamento para UX
    await Future.delayed(const Duration(seconds: 2));

    final bool isAuthenticated = _authService.isAuthenticated();
    final bool hasConsent = await _authService.getConsentStatus();

    String nextRoute;

    if (!hasConsent) {
      // Prioridade 1: Se o consentimento não foi dado, redireciona para a tela de consentimento.
      nextRoute = AppRoutes.consent;
    } else if (isAuthenticated) {
      // Prioridade 2: Se autenticado E já deu consentimento, vai para o Dashboard.
      nextRoute = AppRoutes.dashboard;
    } else {
      // Prioridade 3: Se não autenticado E já deu consentimento, vai para o Login.
      nextRoute = AppRoutes.login;
    }

    // Redireciona e remove a tela de splash da pilha
    if (mounted) {
      Navigator.pushReplacementNamed(context, nextRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        // Placeholder simples para a tela de Splash
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando arquitetura...', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}