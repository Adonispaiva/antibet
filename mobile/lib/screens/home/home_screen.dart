import 'package:flutter/material.dart';

// O HomeScreen é a casca de navegação principal.
// As telas de conteúdo serão construídas nas respectivas pastas (indices, detector, profile).

// Placeholder para as telas que serão desenvolvidas nas próximas iterações
class IndicesScreen extends StatelessWidget {
  const IndicesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Índices e Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)));
  }
}

class DetectorScreen extends StatelessWidget {
  const DetectorScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Detector de Conteúdo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)));
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Perfil e Configurações', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)));
  }
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  // O caminho estático para navegação.
  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Manteremos o StatefulWidget APENAS para gerenciar o estado local do PageView/BottomNavigationBar,
// enquanto o estado de negócio (Auth, Dados) é gerenciado pelo Notifier.
class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const IndicesScreen(),
    const DetectorScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navega para a página sem animação ao tocar no item da barra
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar pode ser removida se cada tela tiver a sua, mas mantemos aqui para a casca
      appBar: AppBar(
        title: const Text('AntiBet - Dashboard'),
        automaticallyImplyLeading: false, 
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // Lógica de Notificações
            },
          ),
        ],
      ),
      
      // PageView para permitir o deslizamento e a troca de telas sem reconstrução completa
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          // Atualiza o índice da barra quando o usuário desliza a tela
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _screens,
      ),
      
      // Barra de navegação inferior
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Índices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes), 
            label: 'Detector',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex, 
        selectedItemColor: Theme.of(context).colorScheme.primary, 
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped, 
      ),
    );
  }
}