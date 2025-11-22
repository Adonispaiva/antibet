import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:antibet/core/notifiers/auth_notifier.dart';
import 'package:antibet/ui/screens/home_screen.dart';
import 'package:antibet/ui/screens/journal_screen.dart';
import 'package:antibet/ui/screens/metrics_screen.dart';
import 'package:antibet/ui/screens/settings_screen.dart'; // Importação adicionada

/// A tela principal do aplicativo após o login, agindo como um container
/// para a navegação por BottomNavigationBar.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  
  // Lista de widgets para cada item da BottomNavigationBar
  // Atualizado para incluir a SettingsScreen
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(), // Tab 0 - Início
    JournalScreen(), // Tab 1 - Diário
    MetricsScreen(), // Tab 2 - Métricas
    SettingsScreen(), // Tab 3 - Configurações (Substituindo o placeholder)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Escuta o AuthNotifier apenas para o logout (aqui é apenas para simulação)
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AntiBet Dashboard'),
        actions: const [
          // Botão de Logout (removido daqui, pois agora está na SettingsScreen)
          // IconButton(
          //   icon: const Icon(Icons.logout),
          //   onPressed: () {
          //     authNotifier.logout(); 
          //   },
          //   tooltip: 'Sair',
          // ),
        ],
      ),
      
      // Corpo exibe o widget selecionado
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      
      // Barra de Navegação Inferior
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Diário',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Métricas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Config',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}