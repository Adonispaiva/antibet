import 'package:flutter/material.dart';

/// Define as constantes de cores do tema visual do aplicativo AntiBet.
/// Isso garante que todas as cores sejam consistentes e facilmente gerenciáveis.
class AppColors {
  // --- Cores Primárias e de Marca ---
  static const Color primaryBlue = Color(0xFF1E88E5); 
  static const Color secondaryDark = Color(0xFF0D47A1);
  static const Color accentGreen = Color(0xFF4CAF50); // Usada para ganhos e sucesso
  static const Color accentRed = Color(0xFFD32F2F);   // Usada para perdas e alertas

  // --- Cores de Fundo e Superfície ---
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // --- Cores de Texto ---
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);

  // --- Cores de Status ---
  static const Color success = Color(0xFF4CAF50);
  static const Color failure = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFC107);
}