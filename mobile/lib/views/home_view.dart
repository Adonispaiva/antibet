import 'package:flutter/material.dart';

// Este Widget representa a View da tela inicial.
// É stateless, focando apenas na representação visual. O gerenciamento de estado
// (se necessário) será delegado a um Controller/Provider/Bloc dedicado.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. App Bar
      appBar: AppBar(
        title: const Text(
          'AntiBet - Autocontrole',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        // Ícones de ações podem ser adicionados aqui (Ex: Configurações, Perfil)
        actions: const [
          // IconButton(
          //   icon: Icon(Icons.settings, color: Colors.white),
          //   onPressed: () {
          //     // Navegar para a tela de Configurações
          //   },
          // ),
        ],
        // Definindo a elevação para dar um destaque na barra
        elevation: 4.0,
      ),
      
      // 2. Body da Tela
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Placeholder temporário. Deve ser substituído por Widgets do Layout Geral.
            Text(
              'Bem-vindo ao AntiBet!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            Text('Aguardando a implementação dos dashboards de controle.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
      
      // 3. Floating Action Button (Placeholder, se aplicável ao fluxo)
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Ação principal da tela
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}