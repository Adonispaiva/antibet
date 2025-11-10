import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:antibet/src/core/notifiers/auth_notifier.dart';
import 'package:antibet/src/core/notifiers/app_config_notifier.dart'; // Exemplo de Notifier a carregar

// Chave para persistência do consentimento (duplicada para uso local)
const String _consentKey = 'user_accepted_consent';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. Simulação do Carregamento de Recursos (5 seg máx)
    await Future.wait([
      // Simula o carregamento dos notifiers críticos (já iniciado no main.dart, mas espera-se o término)
      Provider.of<AuthNotifier>(context, listen: false).checkAuthenticationStatus(), 
      Provider.of<AppConfigNotifier>(context, listen: false).loadConfig(), 
      // Simula um tempo mínimo de exibição para a marca (5 segundos máx)
      Future.delayed(const Duration(seconds: 2)), 
    ]);

    // 2. Lógica de Roteamento Condicional
    final prefs = await SharedPreferences.getInstance();
    final bool hasAcceptedConsent = prefs.getBool(_consentKey) ?? false;
    final bool isLoggedIn = Provider.of<AuthNotifier>(context, listen: false).isLoggedIn;
    
    // Roteamento baseado no estado:
    if (!hasAcceptedConsent) {
      // 1. Não aceitou o consentimento -> Vai para a tela de aceite
      if (mounted) context.go('/consent');
    } else if (!isLoggedIn) {
      // 2. Aceitou, mas não está logado -> Vai para o Cadastro/Login (Rota do Cadastro Inicial)
      // Nota: o AppRouter deve ser configurado para tratar /login vs /register. 
      // Usaremos /register para o fluxo inicial do Onboarding.
      if (mounted) context.go('/register');
    } else {
      // 3. Tudo ok -> Vai para a Home
      if (mounted) context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fundo escuro ou degradê (transmitindo seriedade e acolhimento)
    return Scaffold(
      backgroundColor: Colors.blueGrey[900], 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Logo do AntiBet (em destaque) 
            Image.asset(
              'assets/images/antibet_logo.png', // Substituir pelo caminho real da logo
              height: 150,
            ),
            const SizedBox(height: 30),
            // Slogan: "IA mudando vidas."
            const Text(
              'IA mudando vidas.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 20,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 80),
            const CircularProgressIndicator(color: Colors.white54),
            const SizedBox(height: 80),
            // Logo da Inovexa na base (simulação de texto)
            const Text(
              'Inovexa Software',
              style: TextStyle(
                color: Colors.white30,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}