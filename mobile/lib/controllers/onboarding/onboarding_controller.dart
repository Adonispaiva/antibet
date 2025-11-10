// D:\projetos-inovexa\AntiBet\mobile\lib\controllers\onboarding\onboarding_controller.dart

import 'package:get/get.dart';
import 'package:antibet_mobile/services/auth_service.dart';
import 'package:antibet_mobile/screens/auth/login_screen.dart'; // Próxima tela
// import 'package:antibet_mobile/screens/onboarding/welcome_screen.dart'; // Telas de slides (se necessário)

class OnboardingController extends GetxController {
  final RxBool hasConsented = false.obs;
  late final AuthService _authService;

  @override
  void onInit() {
    super.onInit();
    _authService = Get.find<AuthService>();
    // Verifica imediatamente se o consentimento já foi dado
    _authService.getConsentStatus().then((status) {
      hasConsented.value = status;
    });
  }

  Future<void> acceptConsent() async {
    await _authService.saveConsentStatus(true);
    hasConsented.value = true;
    
    // Navegação após o aceite
    // A tela de Welcome/Slides é a próxima, mas vamos pular diretamente para o login
    // para focar na funcionalidade.
    Get.off(() => const LoginScreen());
  }

  // Método para rotear do Splash/Main
  void checkAndRoute() {
    if (_authService.isAuthenticated()) {
      // Se já está logado, vai direto para o dashboard
      // Get.off(() => const DashboardScreen());
    } else if (hasConsented.value) {
      // Se não está logado, mas já aceitou, vai para o login
      Get.off(() => const LoginScreen());
    } else {
      // Se não aceitou, deve permanecer na ConsentScreen (ou ir para a primeira tela)
      // Get.off(() => const ConsentScreen());
    }
  }
}