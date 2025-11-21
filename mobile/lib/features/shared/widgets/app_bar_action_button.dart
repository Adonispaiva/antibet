import 'package:flutter/material.dart';
import 'package:antibet/core/styles/app_colors.dart';

/// Um widget padronizado para botões de ação na AppBar.
/// Garante que o ícone e a cor de fundo sigam o tema definido.
class AppBarActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final double iconSize;

  const AppBarActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.iconSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: IconButton(
        icon: Icon(
          icon,
          size: iconSize,
          // Cor do ícone deve ser a mesma cor de foreground da AppBar (definida no tema)
          color: color ?? AppColors.textLight, 
        ),
        onPressed: onTap,
      ),
    );
  }
}