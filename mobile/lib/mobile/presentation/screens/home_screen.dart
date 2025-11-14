import 'package:antibet/core/notifiers/push_notification_notifier.dart';
import 'package:antibet/mobile/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:antibet/mobile/presentation/screens/journal/bet_journal_screen.dart';
import 'package:antibet/mobile/presentation/screens/strategy/strategy_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const StrategyScreen(),
    const BetJournalScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Escuta o PushNotificationNotifier para exibir o badge de notificações não lidas
    final notificationNotifier = context.watch<PushNotificationNotifier>();
    final unreadCount = notificationNotifier.unreadCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AntiBet'),
        actions: [
          // 1. Ícone de Notificações com Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => context.go('/notifications'),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
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
          
          // 2. Ícone de Perfil
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/profile'),
          ),
          
          // 3. Ícone de Configurações
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      
      // Conteúdo da tela atual
      body: _screens[_currentIndex],
      
      // Barra de Navegação Inferior
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Estratégias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Histórico',
          ),
        ],
      ),
      
      // Floating Action Button para Adicionar Aposta
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add_bet'),
        child: const Icon(Icons.add),
      ),
    );
  }
}