import 'package:flutter/material.dart';

// Importação placeholder para as telas futuras (serão criadas posteriormente)
// import '../indices/indices_screen.dart';
// import '../detector/detector_screen.dart';
// import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Índice da guia atualmente selecionada no BottomNavigationBar.
  int _selectedIndex = 0;

  // Lista de Widgets que serão exibidos no corpo da tela, correspondente a cada guia.
  // Estes são placeholders e serão substituídos pelas telas reais (IndicesScreen, etc.)
  static const List<Widget> _widgetOptions = <Widget>[
    // 0: Tela de Índices/Dash
    Center(
      child: Text('Tela de Índices e Dashboard (Em desenvolvimento)',
          style: TextStyle(fontSize: 20)),
    ),
    // 1: Tela do Detector/Análise
    Center(
      child: Text('Tela de Detecção de Análise (Em desenvolvimento)',
          style: TextStyle(fontSize: 20)),
    ),
    // 2: Tela de Perfil/Configurações
    Center(
      child: Text('Tela de Perfil e Configurações (Em desenvolvimento)',
          style: TextStyle(fontSize: 20)),
    ),
  ];

  // Função chamada ao tocar em um item da BottomNavigationBar.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AntiBet - Dashboard'),
        automaticallyImplyLeading: false, // Não permite voltar para o Login
        actions: [
          // Botão de Notificações, por exemplo
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // Lógica de Notificações
            },
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex), // Exibe o widget da guia selecionada
      
      // Barra de navegação inferior
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Índices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes), // Ícone sugestivo para 'Detector'
            label: 'Detector',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex, // Garante que o item correto esteja ativo
        selectedItemColor: Theme.of(context).primaryColor, // Cor de destaque
        onTap: _onItemTapped, // Função de manipulação do toque
      ),
    );
  }
}