import 'package:flutter/material.dart';
import 'package:antibet/core/styles/app_colors.dart';

/// Um widget reutilizável para exibir um estado vazio, de erro,
/// ou um chamado para ação (Call to Action - CTA).
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? actionButton;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionButton,
  });

  factory EmptyStateWidget.noData({
    required String title,
    String? subtitle,
    Widget? action,
    Key? key,
  }) {
    return EmptyStateWidget(
      key: key,
      icon: Icons.inbox_outlined,
      title: title,
      subtitle: subtitle ?? 'Ainda não há dados registrados para exibir aqui.',
      actionButton: action,
    );
  }

  factory EmptyStateWidget.error({
    required String title,
    String? subtitle,
    Widget? action,
    Key? key,
  }) {
    return EmptyStateWidget(
      key: key,
      icon: Icons.sentiment_dissatisfied_outlined,
      title: title,
      subtitle: subtitle ?? 'Ocorreu um erro ao tentar carregar as informações.',
      actionButton: action,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 70,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
            if (actionButton != null) ...[
              const SizedBox(height: 24),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }
}