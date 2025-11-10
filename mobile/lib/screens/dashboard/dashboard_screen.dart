// D:\projetos-inovexa\AntiBet\mobile\lib\screens\dashboard\dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antibet_mobile/utils/app_colors.dart';
import 'package:antibet_mobile/utils/app_typography.dart';
import 'package:antibet_mobile/widgets/primary_button.dart';
// import 'package:antibet_mobile/controllers/ai_chat/ai_chat_controller.dart'; 
import 'package:antibet_mobile/services/auth_service.dart'; // Para o botão de Logout

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Get.find<AuthService>();
    // final AiChatController controller = Get.put(AiChatController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Dashboard AntiBet', style: AppTypography.heading3.copyWith(color: AppColors.textPrimary)),
        backgroundColor: AppColors.cardBackground,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: AppColors.secondary),
            onPressed: () {
              authService.logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, Oráculo!', // Pode ser dinâmico no futuro
              style: AppTypography.heading2.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              'Seu próximo palpite analítico está a um clique.',
              style: AppTypography.bodyText.copyWith(color: AppColors.textSecondary),
            ),
            
            const SizedBox(height: 30),

            // Card de Status do Plano
            Card(
              color: AppColors.cardBackground,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Seu Plano Atual', style: AppTypography.label.copyWith(color: AppColors.textSecondary)),
                        Text('Free Plan (5/5 Consultas)', style: AppTypography.heading3.copyWith(color: AppColors.primary)),
                      ],
                    ),
                    Icon(Icons.star_border, color: AppColors.primary, size: 30),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Botão de Ação Principal
            PrimaryButton(
              text: 'Iniciar Consulta de IA',
              onPressed: () {
                // TODO: Navegar para a tela de chat com a IA
                print('Navegar para Chat de IA');
              },
            ),
            
            const SizedBox(height: 30),
            
            // Área para Histórico ou Dicas (futuro)
            Text(
              'Histórico Recente',
              style: AppTypography.heading3.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: Text(
                  'Nenhuma consulta recente. Inicie sua primeira análise.',
                  style: AppTypography.bodyText.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}