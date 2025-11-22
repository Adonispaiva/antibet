// D:\projetos-inovexa\AntiBet\mobile\lib\screens\plans\plans_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antibet_mobile/utils/app_colors.dart';
import 'package:antibet_mobile/utils/app_typography.dart';
import 'package:antibet_mobile/widgets/primary_button.dart';
import 'package:antibet_mobile/controllers/plans/plans_controller.dart';
import 'package:antibet_mobile/services/plans_service.dart'; // Importa o modelo Plan

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PlansController controller = Get.put(PlansController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Catálogo de Planos', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.cardBackground,
        elevation: 1,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value, style: AppTypography.bodyText.copyWith(color: Colors.red)));
        }
        if (controller.plans.isEmpty) {
          return Center(child: Text('Nenhum plano encontrado.', style: AppTypography.bodyText.copyWith(color: AppColors.textSecondary)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.plans.length,
          itemBuilder: (context, index) {
            final plan = controller.plans[index];
            return _buildPlanCard(plan, controller);
          },
        );
      }),
    );
  }

  Widget _buildPlanCard(Plan plan, PlansController controller) {
    bool isFree = plan.price == 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isFree ? AppColors.textSecondary : AppColors.primary, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.name, style: AppTypography.heading2.copyWith(color: isFree ? AppColors.textSecondary : AppColors.primary)),
            const SizedBox(height: 8),
            Text(
              isFree ? 'Grátis' : 'R\$ ${plan.price.toStringAsFixed(2)} / mês',
              style: AppTypography.heading1.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 15),
            Text(plan.description, style: AppTypography.bodyText.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 15),
            Text(
              'Limite de Uso: ${plan.limit} consultas por dia',
              style: AppTypography.label.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 30),
            PrimaryButton(
              text: isFree ? 'Plano Atual' : 'Comprar Agora',
              onPressed: isFree ? null : () => controller.purchasePlan(plan),
              isEnabled: !isFree,
            ),
          ],
        ),
      ),
    );
  }
}