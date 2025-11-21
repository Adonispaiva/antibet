import 'package:flutter/material.dart';
import 'package:antibet/core/styles/app_colors.dart';

/// Um widget de botão que lida nativamente com o estado de loading,
/// substituindo o texto por um indicador de progresso.
class LoadingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final bool isSecondary;
  final double minHeight;

  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.isSecondary = false,
    this.minHeight = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    // Define o estilo de acordo com a propriedade isSecondary
    final Color buttonColor = isSecondary ? Colors.transparent : AppColors.primaryBlue;
    final Color textColor = isSecondary ? AppColors.primaryBlue : AppColors.textLight;

    return SizedBox(
      width: double.infinity,
      height: minHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: textColor,
          // Remove a sombra em botões secundários
          elevation: isSecondary ? 0 : 2, 
          side: isSecondary ? const BorderSide(color: AppColors.primaryBlue, width: 1.5) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isSecondary ? AppColors.primaryBlue : AppColors.textLight,
                  ),
                ),
              )
            : Text(
                text.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}