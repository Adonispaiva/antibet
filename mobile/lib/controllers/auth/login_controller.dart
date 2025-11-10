// D:\projetos-inovexa\AntiBet\mobile\lib\controllers\auth\login_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:antibet_mobile/services/api_service.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Para salvar o token

class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isLoading = false.obs;
  
  late final ApiService _apiService;
  // final _storage = const FlutterSecureStorage();

  @override
  void onInit() {
    super.onInit();
    _apiService = Get.find<ApiService>(); 
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  bool validateLogin() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Erro', 'E-mail e senha são obrigatórios.', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    if (!GetUtils.isEmail(emailController.text)) {
      Get.snackbar('Erro', 'O e-mail inserido é inválido.', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    return true;
  }

  Future<void> submitLogin() async {
    if (!validateLogin()) return;

    isLoading.value = true;

    try {
      final loginData = {
        'email': emailController.text,
        'password': passwordController.text,
      };

      // Chamada para o Backend NestJS /auth/login
      final response = await _apiService.post('/auth/login', loginData);
      
      if (response.statusCode == 200 && response.data != null) {
        final token = response.data['accessToken']; 

        // CRÍTICO: Salvar o Token para autenticação futura
        // await _storage.write(key: 'jwt_token', value: token);
        print('Login bem-sucedido! Token JWT recebido.');

        Get.snackbar('Sucesso', 'Login efetuado!', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.shade600, colorText: Colors.white);
        
        // TODO: Navegar para a Dashboard
        // Get.offAllNamed(AppRoutes.DASHBOARD);

      } else {
        throw Exception('Login falhou: Credenciais inválidas.');
      }

    } on DioException catch (e) {
      String errorMessage = 'Erro de Rede ou Servidor. Verifique o status do Backend.';
      if (e.response?.statusCode == 401) {
        errorMessage = 'Credenciais incorretas. Verifique e-mail e senha.';
      }
      Get.snackbar('Erro de Login', errorMessage, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade600, colorText: Colors.white);

    } catch (e) {
      Get.snackbar('Erro Inesperado', 'Ocorreu um erro durante o login: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade600, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}