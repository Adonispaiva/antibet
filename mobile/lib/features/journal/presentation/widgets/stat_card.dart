import 'packagepackage:flutter/material.dart';

/// [StatCard] é um widget de exibição reutilizável, projetado
/// para mostrar uma única métrica (estatística) no [JournalStats].
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.valueColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Ícone
            Icon(
              icon,
              size: 28.0,
              color: iconColor ?? theme.colorScheme.primary,
            ),
            
            // Informação
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título (ex: "Total de Apostas")
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                // Valor (ex: "10" ou "R$ 150.00")
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}