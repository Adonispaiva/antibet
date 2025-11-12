import 'package:antibet_mobile/core/navigation/app_router.dart';
import 'package:antibet_mobile/models/strategy_model.dart';
import 'package:antibet_mobile/notifiers/auth_notifier.dart';
import 'package:antibet_mobile/notifiers/bet_strategy_notifier.dart';
import 'package:antibet_mobile/notifiers/push_notification_notifier.dart';
import 'package:antibet_mobile/notifiers/user_profile_notifier.dart';
import 'package:antibet_mobile/screens/dashboard_screen.dart';
import 'package:antibet_mobile/screens/bet_journal_screen.dart'; // Importação Adicionada
import 'package:antibet_mobile/screens/strategy_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Tela Principal (Shell de Navegação).
///
/// Esta tela atua como o shell principal do aplicativo após o login,
/// gerenciando o [BottomNavigationBar] para alternar entre as telas principais
/// (Dashboard, Estratégias, Histórico) e a AppBar (Perfil, Configurações, Logout).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Estado para gerenciar a aba selecionada

  // Lista das telas principais do shell
  final List<Widget> _screens = [
    const DashboardScreen(),
    const StrategyListScreen(),
    const BetJournalScreen(), // Adicionada
  ];

  @override
  void initState() {
    super.initState();
    // A lógica de carregamento de dados foi movida para as telas individuais.
  }

  /// Função de callback para o logout.
  void _onLogoutPressed(BuildContext context) {
    context.read<AuthNotifier>().logout();
  }

  /// Navega para a tela de perfil.
  void _onProfilePressed(BuildContext context) {
    Navigator.of(context).pushNamed(AppRouter.profileRoute);
  }

  /// Navega para a tela de configurações.
  void _onSettingsPressed(BuildContext context) {
    Navigator.of(context).pushNamed(AppRouter.settingsRoute);
  }

  /// Navega para a tela de notificações.
  void _onNotificationsPressed(BuildContext context) {
    Navigator.of(context).pushNamed(AppRouter.notificationsRoute);
  }

  /// Atualiza o índice selecionado no BottomNavigationBar.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Retorna o título da AppBar com base na aba selecionada
  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Resumo do AntiBet';
      case 1:
        return 'Estratégias Disponíveis';
      case 2: // Novo índice
        return 'Histórico de Apostas';
      default:
        return 'AntiBet';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observa o perfil do usuário para o AppBar
    final userName = context.watch<UserProfileNotifier>().user?.name ?? 'Usuário';
    
    // Observa o Notifier para obter o número de notificações não lidas
    final unreadCount = context.watch<PushNotificationNotifier>().unreadCount;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_getAppBarTitle()}'),
        actions: [
          // Botão de Notificações (com Badge)
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Notificações',
                onPressed: () => _onNotificationsPressed(context),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error, // Cor de destaque para alerta
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          ),
          
          // Botão de Perfil
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Meu Perfil',
            onPressed: () => _onProfilePressed(context),
          ),
          // Botão de Configurações
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configurações',
            onPressed: () => _onSettingsPressed(context),
          ),
          // Botão de Logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => _onLogoutPressed(context),
          ),
        ],
      ),
      // Exibe a tela correspondente ao índice selecionado
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Estratégias',
          ),
          BottomNavigationBarItem( // Adicionado
            icon: Icon(Icons.history_toggle_off_outlined),
            label: 'Histórico',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Theme.of(context).cardColor,
      ),
    );
  }
}