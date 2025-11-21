import 'package:flutter/material.dart';
import 'package:antibet/core/styles/app_colors.dart';

/// Define o tema visual da aplicação AntiBet (Light Theme).
class AppTheme {
  static ThemeData get lightTheme {
    const Color primaryColor = AppColors.primaryBlue;
    const Color secondaryColor = AppColors.secondaryDark;
    
    return ThemeData(
      useMaterial3: true,
      
      // --- Cores Base ---
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: AppColors.accentRed,
        background: AppColors.backgroundLight,
        surface: AppColors.surfaceLight,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      
      // --- Estilo de AppBar ---
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // --- Estilo de Botões Elevados ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.textLight,
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),
      
      // --- Estilo de Input/Formulários ---
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.textSecondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // --- Estilo de Texto Base ---
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textPrimary),
      ),
    );
  }
  
  // Future: static ThemeData get darkTheme => ...
}