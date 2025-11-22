import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_typography.dart';
// Próxima tela: Cadastro

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingPages = const [
    {
      'title': 'Você não está sozinho.',
      'subtitle': 'Milhares de pessoas enfrentam o vício em apostas. Estamos aqui para te apoiar, sem julgamentos.'
    },
    {
      'title': 'Vamos te ajudar a entender e vencer o vício.',
      'subtitle': 'Com o apoio da Inteligência Artificial e técnicas psicológicas, vamos retomar o controle da sua vida.'
    },
    {
      'title': 'Sua privacidade é nossa prioridade.',
      'subtitle': 'O AntiBet respeita suas decisões e mantém seus dados seguros, com foco em sua recuperação.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: Padding(
        padding: const EdgeInsets.only(top: 80.0, left: 24, right: 24, bottom: 40),
        child: Column(
          children: <Widget>[
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingPages.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingSlide(
                    title: _onboardingPages[index]['title']!,
                    subtitle: _onboardingPages[index]['subtitle']!,
                    pageNumber: index + 1,
                  );
                },
              ),
            ),
            
            // Indicadores de Página
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingPages.length,
                (index) => buildDot(index, context),
              ),
            ),
            const SizedBox(height: 32),

            // Botão Principal
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (_currentPage < _onboardingPages.length - 1) {
                  // Passa para o próximo slide
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeIn,
                  );
                } else {
                  // Navega para a Tela de Cadastro (Final do Onboarding)
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      // Devemos criar esta tela no próximo chat
                      builder: (context) => const Center(child: Text("Tela de Cadastro Inicial")),
                    ),
                  );
                }
              },
              child: Text(
                _currentPage < _onboardingPages.length - 1 ? 'Próximo' : 'Quero Começar',
                style: AppTypography.labelLarge.copyWith(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 6,
      width: _currentPage == index ? 24 : 6,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primaryBlue : AppColors.textSecondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class OnboardingSlide extends StatelessWidget {
  final String title;
  final String subtitle;
  final int pageNumber;

  const OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.pageNumber,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // Placeholder para ilustração/ícone
        Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: Text(
              '$pageNumber',
              style: AppTypography.displayLarge.copyWith(color: AppColors.primaryBlue),
            ),
          ),
        ),
        const SizedBox(height: 48),
        Text(
          title,
          style: AppTypography.headlineLarge.copyWith(fontSize: 34),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          subtitle,
          style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}