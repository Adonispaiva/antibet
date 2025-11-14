// mobile/lib/widgets/splash_screen.dart

import 'package.flutter/material.dart';

/// Tela exibida durante o carregamento inicial do aplicativo,
/// especificamente enquanto o AuthNotifier verifica o token persistido.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blue, // Cor de fundo alinhada com o tema
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder para o Logo do AntiBet
            Icon(
              Icons.shield, // Ícone de "Escudo" (AntiBet)
              size: 80,
              color: Colors.white,
            ),
            SizedBox(height: 16),
            Text(
              'AntiBet',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}