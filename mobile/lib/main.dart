import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/presentation/login_screen.dart';

// Ponto de entrada da aplicação
void main() {
  // O ProviderScope é essencial para o Riverpod gerenciar o estado (Auth, Chat, etc)
  runApp(const ProviderScope(child: AntiBetApp()));
}

class AntiBetApp extends StatelessWidget {
  const AntiBetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AntiBet',
      debugShowCheckedModeBanner: false, // Remove a faixa de "Debug" no canto
      
      // === SISTEMA DE DESIGN (TEMA) ===
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        useMaterial3: true,
        
        // Definição de Cores Semânticas
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal,
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFF009688), // Teal padrão
          secondary: const Color(0xFFFFC107), // Amber para destaque/alertas
          surface: const Color(0xFF1E1E1E), // Fundo quase preto
          error: const Color(0xFFCF6679), // Vermelho suave para erros
        ),

        // Tipografia Global
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          bodyLarge: TextStyle(fontSize: 16),
        ),

        // Estilo Padrão de Botões
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF009688),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
          ),
        ),

        // Estilo de Inputs
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF009688), width: 2),
          ),
        ),
      ),

      // === ROTA INICIAL ===
      // Inicia diretamente na tela de Login, que agora leva ao Dashboard
      home: const LoginScreen(),
    );
  }
}