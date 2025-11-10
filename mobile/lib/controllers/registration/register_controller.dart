// D:\projetos-inovexa\AntiBet\mobile\lib\controllers\registration\register_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart'; // Importado para lidar com exceções do Dio
import 'package:antibet_mobile/services/api_service.dart'; 
import 'package:antibet_mobile/screens/registration/register_credentials_screen.dart'; 
// import 'package:antibet_mobile/routes/app_routes.dart'; // Para navegação final

class RegisterController extends GetxController {
  // Estado da Tela 1: Informações Pessoais (Para personalização da IA)
  final TextEditingController avatarNameController = TextEditingController();
  final TextEditingController birthYearController = TextEditingController();
  final RxString gender = 'Masculino'.obs; // Valor padrão

  // Estado da Tela 2: Credenciais (Para autenticação)
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final RxBool isLoading = false.obs;
  
  // CRÍTICO: Injeção do ApiService
  late final ApiService _apiService;

  @override
  void onInit() {
    super.onInit();
    // Encontra a instância global do ApiService
    _apiService = Get.find<ApiService>(); 
  }

  @override
  void onClose() {
    avatarNameController.dispose();
    birthYearController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // --- MÉTODOS DE VALIDAÇÃO E NAVEGAÇÃO ---

  bool validatePersonalInfo() {
    if (avatarNameController.text.isEmpty || 
        birthYearController.text.isEmpty ||
        gender.value.isEmpty) {
      Get.snackbar('Erro de Validação', 'Por favor, preencha todos os campos.', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    // Adicionar validação de ano (Ex: deve ser um número, deve ser razoável)
    if (int.tryParse(birthYearController.text) == null) {
      Get.snackbar('Erro de Validação', 'O ano de nascimento deve ser um número válido.', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    return true;
  }

  void goToCredentialsStep() {
    if (validatePersonalInfo()) {
      // Navega para a próxima tela.
      Get.to(() => const RegisterCredentialsScreen()); 
    }
  }

  // --- MÉTODOS DE SUBMISSÃO FINAL ---

  bool validateCredentials() {
    if (emailController.text.isEmpty || 
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar('Erro de Validação', 'E-mail e Senhas são obrigatórios.', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Erro de Senha', 'As senhas não coincidem.', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    // Validação básica de formato de e-mail (pode ser aprimorada)
    if (!GetUtils.isEmail(emailController.text)) {
      Get.snackbar('Erro de Validação', 'O e-mail inserido é inválido.', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    return true;
  }

  Future<void> submitRegistration() async {
    if (!validateCredentials()) return;

    isLoading.value = true;

    try {
      final userData = {
        'email': emailController.text,
        'password': passwordController.text,
        'avatarName': avatarNameController.text,
        'birthYear': int.tryParse(birthYearController.text),
        'gender': gender.value,
      };

      // CRÍTICO: Chamada real para o Backend NestJS
      final response = await _apiService.post('/auth/register', userData);
      
      if (response.statusCode == 201) {
        // Sucesso no registro (HTTP 201 Created)
        Get.snackbar('Sucesso', 'Seu cadastro foi concluído!', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.shade600, colorText: Colors.white);
        
        // TODO: Navegação para a tela principal ou login
        // Get.offAllNamed(AppRoutes.LOGIN); 

      } else {
        // Tratamento de outros status de sucesso que podem ser inesperados
        throw Exception('Registro falhou com status: ${response.statusCode}');
      }

    } on DioException catch (e) {
      String errorMessage = 'Erro de Rede. Verifique sua conexão ou servidor.';
      if (e.response != null && e.response!.data != null) {
         // Assume que o backend retorna { "message": ["email already exists"] }
        errorMessage = e.response!.data['message']?.toString() ?? 'Erro desconhecido no servidor.';
        if (errorMessage.contains('already exists')) {
          errorMessage = 'O e-mail fornecido já está em uso.';
        }
      }
      Get.snackbar('Erro de Registro', errorMessage, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade600, colorText: Colors.white);

    } catch (e) {
      Get.snackbar('Erro Inesperado', 'Ocorreu um erro ao tentar registrar: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade600, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}