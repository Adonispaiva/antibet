// D:\projetos-inovexa\AntiBet\mobile\lib\screens\auth\login_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:antibet_mobile/utils/app_colors.dart';
import 'package:antibet_mobile/utils/app_typography.dart';
import 'package:antibet_mobile/widgets/custom_text_field.dart';
import 'package:antibet_mobile/widgets/primary_button.dart';
import 'package:antibet_mobile/controllers/auth/login_controller.dart'; 
// import 'package:antibet_mobile/screens/registration/register_personal_info_screen.dart'; // Para link de cadastro

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inicializa o Controller na View
    final LoginController controller = Get.put(LoginController()); 

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 50),
            
            // Título
            Text(
              'Bem-vindo(a) de Volta',
              style: AppTypography.heading1.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Acesse sua conta AntiBet para continuar.',
              style: AppTypography.bodyText.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 60),

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
              hintText: 'Sua senha secreta',
              obscureText: true,
              controller: controller.passwordController,
            ),
            
            const SizedBox(height: 10),
            
            // Link para redefinição de senha
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Implementar navegação para tela de Reset de Senha
                  print('Navegar para Reset de Senha');
                },
                child: Text(
                  'Esqueceu a senha?',
                  style: AppTypography.label.copyWith(color: AppColors.secondary),
                ),
              ),
            ),
            
            const SizedBox(height: 40),

            // Botão de Login
            Obx(
              () => PrimaryButton(
                text: controller.isLoading.value ? 'Autenticando...' : 'Entrar',
                onPressed: controller.isLoading.value 
                    ? null 
                    : controller.submitLogin,
              ),
            ),

            const SizedBox(height: 60),
            
            // Link para Cadastro
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Não tem uma conta?',
                  style: AppTypography.bodyText.copyWith(color: AppColors.textSecondary),
                ),
                TextButton(
                  onPressed: () {
                    // Navegar para a primeira tela de registro
                    // Get.to(() => const RegisterPersonalInfoScreen()); 
                    print('Navegar para Cadastro');
                  },
                  child: Text(
                    'Cadastre-se Agora',
                    style: AppTypography.label.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}