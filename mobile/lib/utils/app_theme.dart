import 'package:flutter/material.dart';
import 'package:inovexa_antibet/utils/app_colors.dart';
import 'package:inovexa_antibet/utils/app_typography.dart';

/// Define o tema visual global (Light/Dark) para a aplicação.
/// Utiliza as constantes de AppColors e AppTypography.
class AppTheme {
  
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      
      // Esquema de Cores
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
        onPrimary: AppColors.textLight,
        onSecondary: AppColors.textLight,
        onSurface: AppColors.textDark,
        onError: AppColors.textLight,
      ),

      // Tema da AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.title.copyWith(color: AppColors.textDark),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),

      // Tema de Botões
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          textStyle: AppTypography.button,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // Tema de TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.body,
        ),
      ),

      // Tema de Campos de Formulário
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: AppTypography.body.copyWith(color: AppColors.textDark.withOpacity(0.6)),
        hintStyle: AppTypography.body.copyWith(color: AppColors.textDark.withOpacity(0.4)),
      ),

      // Define a tipografia padrão
      textTheme: TextTheme(
        displayLarge: AppTypography.title.copyWith(fontSize: 34),
        displayMedium: AppTypography.title.copyWith(fontSize: 28),
        headlineMedium: AppTypography.title, // Usado por AppLayout
        bodyMedium: AppTypography.body,
        labelLarge: AppTypography.button, // Usado por ElevatedButton
      ),
    );
  }

  // TODO: Definir o tema escuro (DarkTheme) em uma sessão futura.
  static ThemeData get darkTheme {
    // Por enquanto, retorna o tema claro como placeholder, mas
    // com brilho escuro para que os componentes do sistema se adaptem.
    return lightTheme.copyWith(brightness: Brightness.dark); 
  }
}