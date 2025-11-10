// D:\projetos-inovexa\AntiBet\mobile\lib\screens\registration\register_credentials_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antibet_mobile/utils/app_colors.dart';
import 'package:antibet_mobile/utils/app_typography.dart';
import 'package:antibet_mobile/widgets/custom_text_field.dart';
import 'package:antibet_mobile/widgets/primary_button.dart';
import 'package:antibet_mobile/controllers/registration/register_controller.dart'; 

class RegisterCredentialsScreen extends StatelessWidget {
  const RegisterCredentialsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Injeta o controlador para garantir que ele está pronto
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
              'Credenciais de Acesso',
              style: AppTypography.heading1.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Seu e-mail será seu login. Escolha uma senha forte.',
              style: AppTypography.bodyText.copyWith(color: AppColors.textSecondary),
            ),
            
            const SizedBox(height: 40),

            // Campo de E-mail
            CustomTextField(
              label: 'E-mail',
              hintText: 'seu.email@exemplo.com',
              keyboardType: TextInputType.emailAddress,
              controller: controller.emailController,
            ),
            const SizedBox(height: 20),

            // Campo de Senha
            CustomTextField(
              label: 'Senha',
              hintText: 'Mínimo de 8 caracteres',
              obscureText: true,
              controller: controller.passwordController,
            ),
            const SizedBox(height: 20),

            // Campo de Confirmação de Senha
            CustomTextField(
              label: 'Confirmar Senha',
              hintText: 'Repita a senha',
              obscureText: true,
              controller: controller.confirmPasswordController,
            ),
            
            const SizedBox(height: 60),

            // Botão de Submissão Final
            Obx(
              () => PrimaryButton(
                text: controller.isLoading.value ? 'Registrando...' : 'Finalizar Cadastro',
                onPressed: controller.isLoading.value 
                    ? null // Desabilita o botão enquanto carrega
                    : controller.submitRegistration,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}