import 'package:flutter/material.dart';
import 'package:antibet/core/styles/app_colors.dart';

/// Um widget de cartão reutilizável projetado para exibir um item de lista
/// ou um resumo de métrica no Dashboard ou em listas de features.
class DashboardItemCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final Color? color;
  final VoidCallback? onTap;

  const DashboardItemCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Cor de fundo padrão, caindo para a cor primária se nula
    final cardColor = color ?? AppColors.primaryBlue;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // --- Ícone de Destaque ---
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconTheme(
                  data: IconThemeData(color: cardColor, size: 24),
                  child: icon,
                ),
              ),
              const SizedBox(width: 16),

              // --- Título e Subtítulo ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // --- Indicador de Ação ---
              if (onTap != null)
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}