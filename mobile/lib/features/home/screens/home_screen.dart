// mobile/lib/features/home/screens/home_screen.dart

import 'package:antibet/features/ai_chat/screens/ai_chat_screen.dart';
import 'package:antibet/features/goals/screens/goals_screen.dart';
import 'package:antibet/features/user/screens/user_profile_screen.dart';
import 'packagepackage:flutter/material.dart';

// Importações reais das telas (substituindo os placeholders)
import 'package:antibet/features/metrics/screens/metrics_dashboard_screen.dart';
import 'package:antibet/features/journal/screens/journal_screen.dart';


/// Tela Principal (Home) do aplicativo.
/// Gerencia a navegação principal usando uma BottomNavigationBar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // O índice da aba selecionada

  // Lista de telas que serão exibidas pela navegação
  // Agora com as telas reais
  static const List<Widget> _pages = <Widget>[
    MetricsDashboardScreen(), // Aba 0: Métricas/Dashboard (Real)
    JournalScreen(), // Aba 1: Diário (Real)
    GoalsScreen(), // Aba 2: Metas (Real)
    AiChatScreen(), // Aba 3: AI Chat (Real)
    UserProfileScreen(), // Aba 4: Perfil (Real)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Métricas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Diário',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_outlined),
            activeIcon: Icon(Icons.flag),
            label: 'Metas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bubble_chart_outlined),
            activeIcon: Icon(Icons.bubble_chart),
            label: 'Assistente IA',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // Cor do item selecionado
        unselectedItemColor: Colors.grey.shade600, // Cor dos itens não selecionados
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed, // Garante que todos os itens sejam exibidos
        onTap: _onItemTapped,
      ),
    );
  }
}