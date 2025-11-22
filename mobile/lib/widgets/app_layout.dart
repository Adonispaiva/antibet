import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_typography.dart';

/// Widget de layout base usado por todas as telas do aplicativo.
/// Garante consistência de fundo, tema e estrutura básica.
class AppLayout extends StatelessWidget {
  final String? title;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const AppLayout({
    super.key,
    this.title,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fundo definido no ThemeData (AppColors.mainBackground)
      appBar: title != null
          ? AppBar(
              title: Text(
                title!,
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              centerTitle: true,
              // Ícone de menu ou voltar será adicionado em lotes futuros
            )
          : null,
      body: SafeArea(
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}