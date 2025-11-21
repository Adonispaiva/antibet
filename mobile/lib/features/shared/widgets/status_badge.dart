import 'package:flutter/material.dart';
import 'package:antibet/core/styles/app_colors.dart';

/// Um widget pequeno e reutilizável para exibir status, tags ou valores
/// com cores de fundo baseadas no significado (ex: sucesso, falha, neutro).
class StatusBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor = AppColors.textLight,
    this.icon,
  });

  factory StatusBadge.success(String text, {Key? key}) {
    return StatusBadge(
      key: key,
      text: text,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_outline,
    );
  }

  factory StatusBadge.failure(String text, {Key? key}) {
    return StatusBadge(
      key: key,
      text: text,
      backgroundColor: AppColors.failure,
      icon: Icons.error_outline,
      textColor: AppColors.textLight,
    );
  }

  factory StatusBadge.warning(String text, {Key? key}) {
    return StatusBadge(
      key: key,
      text: text,
      backgroundColor: AppColors.warning,
      icon: Icons.warning_amber_rounded,
      textColor: AppColors.textPrimary, // Cor escura para melhor contraste em amarelo
    );
  }

  factory StatusBadge.neutral(String text, {Key? key}) {
    return StatusBadge(
      key: key,
      text: text,
      backgroundColor: Colors.grey[400],
      textColor: AppColors.textPrimary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Icon(
                icon,
                size: 14,
                color: textColor,
              ),
            ),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}