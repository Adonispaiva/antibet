import 'package:flutter/material.dart';

/// Classe responsável por centralizar a definição dos temas (claro e escuro)
/// do aplicativo, garantindo consistência visual.
class AppTheme {
  // Cores Primárias Comuns
  static const Color primaryColor = Color(0xFF00C853); // Um verde vibrante (AntiBet!)
  static const Color accentColor = Color(0xFF2962FF); // Azul para detalhes/botões

  // =========================================================================
  // TEMA CLARO (LIGHT THEME)
  // =========================================================================
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    
    // Configurações do App Bar (Fundo branco, texto escuro)
    appBarTheme: const AppBarTheme(
      color: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
    ),

    // Configurações do Esquema de Cores
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: const MaterialColor(
        0xFF00C853,
        <int, Color>{
          50: Color(0xFFE0F7FA),
          100: Color(0xFFB2EBF2),
          200: Color(0xFF80DEEA),
          300: Color(0xFF4DD0E1),
          400: Color(0xFF26C6DA),
          500: primaryColor,
          600: Color(0xFF00C853),
          700: Color(0xFF00C853),
          800: Color(0xFF00C853),
          900: Color(0xFF00C853),
        },
      ),
      accentColor: accentColor,
      backgroundColor: const Color(0xFFF5F5F5), // Fundo principal claro
      cardColor: Colors.white,
    ).copyWith(
      secondary: accentColor,
    ),
    
    // Configuração de Textos
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    
    // Configuração de Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
  );

  // =========================================================================
  // TEMA ESCURO (DARK THEME)
  // =========================================================================
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    
    // Configurações do App Bar (Fundo escuro, texto claro)
    appBarTheme: const AppBarTheme(
      color: Color(0xFF1E1E1E), // Preto mais suave
      foregroundColor: Colors.white,
      elevation: 1,
    ),
    
    // Configurações do Esquema de Cores
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: const MaterialColor(
        0xFF00C853,
        <int, Color>{
          50: Color(0xFFE0F7FA),
          100: Color(0xFFB2EBF2),
          200: Color(0xFF80DEEA),
          300: Color(0xFF4DD0E1),
          400: Color(0xFF26C6DA),
          500: primaryColor,
          600: Color(0xFF00C853),
          700: Color(0xFF00C853),
          800: Color(0xFF00C853),
          900: Color(0xFF00C853),
        },
      ),
      accentColor: accentColor,
      backgroundColor: const Color(0xFF121212), // Fundo principal escuro
      cardColor: const Color(0xFF1E1E1E),
    ).copyWith(
      secondary: accentColor,
    ),
    
    // Cor de fundo do Scaffold
    scaffoldBackgroundColor: const Color(0xFF121212),

    // Configuração de Textos
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    
    // Configuração de Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
  );
}