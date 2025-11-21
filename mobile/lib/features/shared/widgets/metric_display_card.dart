import 'package:flutter/material.dart';
import 'package:antibet/core/styles/app_colors.dart';
import 'package:intl/intl.dart';

/// Um widget reutilizável para exibir métricas financeiras importantes (KPIs),
/// como P&L, ROI ou Saldo, com indicação visual de performance (verde/vermelho).
class MetricDisplayCard extends StatelessWidget {
  final String title;
  final double value;
  final String unit; // Ex: '%', 'R$', 'USD'
  final bool isFinancial;
  final bool showSign;

  const MetricDisplayCard({
    super.key,
    required this.title,
    required this.value,
    this.unit = 'R\$',
    this.isFinancial = true,
    this.showSign = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPositive = value >= 0;
    
    // Define a cor com base no valor (verde para positivo/zero, vermelho para negativo)
    final Color valueColor = isPositive ? AppColors.accentGreen : AppColors.accentRed;

    // Formatação da moeda/valor
    String formattedValue;
    if (isFinancial && unit == 'R\$') {
      final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
      formattedValue = formatter.format(value.abs());
    } else {
      // Formato geral para porcentagens ou outras unidades
      formattedValue = value.abs().toStringAsFixed(2);
      if (unit.isNotEmpty) {
        formattedValue += unit;
      }
    }

    // Adiciona o sinal de + ou -
    String sign = '';
    if (showSign) {
      sign = isPositive ? (value == 0 ? '' : '+') : '-';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Título/Descrição ---
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            // --- Valor Principal (Com Sinal e Cor) ---
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: valueColor,
                      fontSize: 28,
                    ),
                children: [
                  TextSpan(text: sign),
                  TextSpan(text: formattedValue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}