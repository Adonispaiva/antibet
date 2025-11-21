import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:antibet/core/routing/app_router.dart';
import 'package:antibet/features/shared/widgets/app_bar_action_button.dart';
import 'package:antibet/core/styles/app_colors.dart';

// O decorator @RoutePage() é exigido pelo auto_route para gerar a rota correspondente.
@RoutePage() 
class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // O AutoTabsRouter é o widget que gerencia a navegação das abas internas
    return AutoTabsRouter(
      // Lista as rotas que serão carregadas em cada aba (aquelas definidas como filhas no app_router.dart)
      routes: const [
        HomeRoute(), 
        JournalRoute(), 
        GoalsRoute(),
      ],
      
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          appBar: AppBar(
            // O título pode ser dinâmico com base na aba
            title: _getAppBarTitle(tabsRouter.activeIndex),
            // Remove o botão de voltar automático quando aninhado
            automaticallyImplyLeading: false, 
            actions: [
              // Botão para Notificações
              AppBarActionButton(
                icon: Icons.notifications_none,
                onTap: () {
                  context.router.push(const NotificationRoute());
                },
              ),
              // Botão para Perfil
              AppBarActionButton(
                icon: Icons.person_outline,
                onTap: () {
                  context.router.push(const ProfileRoute());
                },
              ),
            ],
          ),
          
          // O Body exibe a tela da aba atualmente selecionada
          body: child, 
          
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: tabsRouter.activeIndex,
            onTap: tabsRouter.setActiveIndex,
            // Cores do tema
            selectedItemColor: AppColors.primaryBlue,
            unselectedItemColor: AppColors.textSecondary,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book_outlined),
                activeIcon: Icon(Icons.book),
                label: 'Diário',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.track_changes_outlined),
                activeIcon: Icon(Icons.track_changes),
                label: 'Metas',
              ),
            ],
          ),
        );
      },
    );
  }

  /// Retorna o título da AppBar com base na aba ativa.
  Widget _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return const Text('Dashboard');
      case 1:
        return const Text('Diário de Trades');
      case 2:
        return const Text('Minhas Metas');
      default:
        return const Text('AntiBet');
    }
  }
}