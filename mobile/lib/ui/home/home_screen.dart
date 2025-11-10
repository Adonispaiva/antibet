import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:antibet/notifiers/auth/auth_notifier.dart';

/// Tela Principal do Aplicativo (HomeScreen)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Placeholder para as telas que serão navegadas no BottomNavigationBar
  static const List<Widget> _widgetOptions = <Widget>[
    Center(child: Text('Dashboard (Visão Geral)')),
    Center(child: Text('Analytics Comportamental')),
    Center(child: Text('Configurações & Suporte')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // TODO: Integrar com LockdownNotifier e LockdownService
  void _activatePanicMode() {
    // Lógica para ativar o bloqueio (Botão de Pânico)
    // Ex: context.read<LockdownNotifier>().activateLockdown();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modo de Pânico Ativado'),
          content: const Text(
              'O bloqueio total do aplicativo foi solicitado. Você será desconectado e a tela de bloqueio será exibida.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleLogout(BuildContext context) {
    // Lógica para chamar o logout no Notifier
    context.read<AuthNotifier>().logout();
  }

  @override
  Widget build(BuildContext context) {
    // Observa o estado de loading do AuthNotifier para desabilitar ações durante o processamento.
    final authNotifier = context.watch<AuthNotifier>();
    final bool isLoading = authNotifier.isLoading;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('AntiBet - Seu Hub de Segurança'),
        actions: [
          // Botão de Pânico (Lockdown/Missão Anti-Vício)
          IconButton(
            icon: const Icon(Icons.shield_moon_rounded, color: Colors.redAccent),
            onPressed: isLoading ? null : _activatePanicMode, // Desabilita se estiver carregando
            tooltip: 'Ativar Modo de Pânico (Bloqueio Total)',
          ),
          // Botão de Logout
          IconButton(
            icon: isLoading 
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : const Icon(Icons.logout),
            onPressed: isLoading ? null : () => _handleLogout(context), // Desabilita se estiver carregando
            tooltip: 'Sair do AntiBet',
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Configurações',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: isLoading ? null : _onItemTapped, // Desabilita navegação se estiver carregando
      ),
    );
  }
}