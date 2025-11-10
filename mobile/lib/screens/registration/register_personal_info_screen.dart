// D:\projetos-inovexa\AntiBet\mobile\lib\screens\registration\register_personal_info_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Importações de utilitários
import 'package:antibet_mobile/utils/app_colors.dart';
import 'package:antibet_mobile/utils/app_typography.dart';
import 'package:antibet_mobile/widgets/custom_text_field.dart';
import 'package:antibet_mobile/widgets/primary_button.dart';
import 'package:antibet_mobile/controllers/registration/register_controller.dart'; // NOVO

class RegisterPersonalInfoScreen extends StatelessWidget {
  const RegisterPersonalInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inicializa o Controller. Se ele já existir, o GetX o retorna.
    final RegisterController controller = Get.put(RegisterController()); 

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Fale-nos um pouco sobre você',
              style: AppTypography.heading1.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Estas informações ajudarão a AntiBet a personalizar sua experiência de IA.',
              style: AppTypography.bodyText.copyWith(color: AppColors.textSecondary),
            ),
            
            const SizedBox(height: 40),

            // Campo de Nome (AvatarName)
            CustomTextField(
              label: 'Seu Nome de Usuário/Avatar',
              hintText: 'Ex: Oráculo, BetMaster',
              controller: controller.avatarNameController, // LIGADO AO CONTROLLER
            ),
            const SizedBox(height: 20),

            // Campo de Ano de Nascimento (birthYear)
            CustomTextField(
              label: 'Ano de Nascimento',
              hintText: 'Ex: 1995',
              keyboardType: TextInputType.number,
              controller: controller.birthYearController, // LIGADO AO CONTROLLER
            ),
            const SizedBox(height: 20),

            // Campo de Gênero (gender)
            Text(
              'Gênero',
              style: AppTypography.label.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Obx(() => DropdownButtonFormField<String>( // Obx para reagir à mudança inicial
                value: controller.gender.value, // Usa o estado reativo
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Selecione',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                ),
                items: ['Masculino', 'Feminino', 'Outro', 'Prefiro não informar']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: AppTypography.bodyText),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.gender.value = newValue; // Atualiza o estado reativo
                  }
                },
                isExpanded: true,
                dropdownColor: AppColors.cardBackground,
                style: AppTypography.bodyText.copyWith(color: AppColors.textPrimary),
              )),
            ),

            const SizedBox(height: 60),

            // Botão de Próximo Passo
            PrimaryButton(
              text: 'Continuar para Credenciais',
              onPressed: () {
                controller.goToCredentialsStep(); // CHAMADA CORRETA DE NAVEGAÇÃO
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}