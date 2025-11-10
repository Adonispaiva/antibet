import 'package:flutter/material.dart';
import 'package:inovexa_antibet/screens/onboarding/auth_screen.dart';
import 'package:inovexa_antibet/screens/onboarding/consent_screen.dart';
import 'package:inovexa_antibet/screens/onboarding/registration_screen.dart';
import 'package:inovexa_antibet/screens/onboarding/splash_screen.dart';
import 'package:inovexa_antibet/screens/onboarding/welcome_screen.dart';

/// Gerencia o fluxo de navegação completo do Onboarding.
///
/// Este widget é um 'StatefulWidget' que atua como um roteador interno
/// para as telas de Onboarding, garantindo que o usuário passe por todas
/// as etapas necessárias (Splash -> Consent -> Welcome -> Registration -> Auth)
/// antes de ser considerado "pronto" para o fluxo principal (HomeScreen).
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  // Usamos um Navigator local para o fluxo de onboarding
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/splash':
            return _buildPageRoute(
              SplashScreen(
                // Navega para a próxima etapa (Consent) após o splash
                onComplete: () => _navigateTo('/consent'),
              ),
            );
          case '/consent':
            return _buildPageRoute(
              ConsentScreen(
                // Navega para Welcome
                onConsentGiven: () => _navigateTo('/welcome'),
              ),
            );
          case '/welcome':
            return _buildPageRoute(
              WelcomeScreen(
                // Navega para Registration
                onComplete: () => _navigateTo('/registration'),
              ),
            );
          case '/registration':
            return _buildPageRoute(
              RegistrationScreen(
                // Navega para Auth (tela final de login/senha)
                onComplete: () => _navigateTo('/auth'),
              ),
            );
          case '/auth':
            // A AuthScreen é a última etapa. Se o login for bem-sucedido,
            // o Consumer no 'main.dart' (AuthGate) trocará este 'OnboardingFlow'
            // pelo 'HomeScreen'.
            return _buildPageRoute(const AuthScreen());
          default:
            // Rota de fallback segura
            return _buildPageRoute(
              SplashScreen(onComplete: () => _navigateTo('/consent')),
            );
        }
      },
    );
  }

  /// Navega para uma nova rota substituindo a atual (para não poder voltar).
  void _navigateTo(String routeName) {
    // Garante que o widget ainda está montado antes de navegar
    if (mounted) {
      _navigatorKey.currentState?.pushReplacementNamed(routeName);
    }
  }

  /// Helper para construir a rota com transição de Fade.
  PageRouteBuilder _buildPageRoute(Widget child) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}