import 'package:flutter/material.dart';
import 'package:antibet/core/styles/app_colors.dart';

/// Um widget separador visualmente discreto, usado para dividir
/// grupos de ações ou seções de conteúdo em formulários e telas de detalhe.
class ActionSeparator extends StatelessWidget {
  const ActionSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      height: 1.0,
      color: AppColors.textSecondary.withOpacity(0.3),
    );
  }
}