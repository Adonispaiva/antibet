// D:\projetos-inovexa\AntiBet\mobile\lib\screens\onboarding\consent_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antibet_mobile/utils/app_colors.dart';
import 'package:antibet_mobile/utils/app_typography.dart';
import 'package:antibet_mobile/widgets/primary_button.dart';
import 'package:antibet_mobile/controllers/onboarding/onboarding_controller.dart'; 

class ConsentScreen extends StatelessWidget {
  const ConsentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicializa o Controller. Ele verifica o estado do consentimento no init.
    final OnboardingController controller = Get.put(OnboardingController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.gavel, size: 60, color: AppColors.secondary),
            const SizedBox(height: 20),
            Text(
              'Compromisso Ético e Legal',
              style: AppTypography.heading2.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              'A AntiBet utiliza IA para análise de dados e tendências, não garantindo lucro ou sucesso em apostas. O uso da plataforma deve ser ético, legal e consciente.',
              style: AppTypography.bodyText.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            _buildConsentPoint('Maioridade Legal', 'Você confirma ter a idade legal para utilizar serviços de análise.', Icons.check_circle_outline),
            _buildConsentPoint('Uso Pessoal e Ético', 'Você concorda em usar as análises de forma responsável, sem redistribuição comercial.', Icons.security),
            _buildConsentPoint('Sem Garantia de Lucro', 'Você entende que a IA é uma ferramenta de apoio, e não uma promessa de retorno financeiro.', Icons.warning_amber),
            
            const SizedBox(height: 50),

            PrimaryButton(
              text: 'Aceitar Termos e Continuar',
              onPressed: controller.acceptConsent,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildConsentPoint(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.label.copyWith(color: AppColors.textPrimary)),
                Text(subtitle, style: AppTypography.bodyText.copyWith(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}