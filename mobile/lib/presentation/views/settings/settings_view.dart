import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:antibet/src/core/notifiers/app_config_notifier.dart';
import 'package:antibet/src/core/notifiers/auth_notifier.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  // Função para lidar com o Logout
  Future<void> _handleLogout(BuildContext context) async {
    final authNotifier = context.read<AuthNotifier>();
    await authNotifier.logout();
    
    // O AppRouter deve redirecionar automaticamente para a tela de Login/Register
    if (context.mounted) context.go('/login'); 
  }

  @override
  Widget build(BuildContext context) {
    final configNotifier = context.watch<AppConfigNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // SEÇÃO 1: CONFIGURAÇÕES GERAIS
            _buildSectionTitle('Geral'),
            Card(
              elevation: 1,
              child: SwitchListTile(
                title: const Text('Modo Escuro (Dark Mode)'),
                subtitle: const Text('Aplica o tema escuro para maior conforto visual.'),
                secondary: const Icon(Icons.dark_mode_outlined),
                value: configNotifier.isDarkMode,
                onChanged: (newValue) {
                  configNotifier.toggleDarkMode(newValue);
                },
              ),
            ),
            
            const SizedBox(height: 30),

            // SEÇÃO 2: CONTA E SEGURANÇA
            _buildSectionTitle('Conta e Segurança'),
            _buildSettingsTile(
              context, 
              title: 'Alterar Senha', 
              icon: Icons.key_outlined, 
              onTap: () => context.go('/settings/change-password'),
            ),
            _buildSettingsTile(
              context, 
              title: 'Gerenciar Dados Pessoais', 
              icon: Icons.person_outline, 
              onTap: () => context.go('/settings/data-management'),
            ),
            _buildSettingsTile(
              context, 
              title: 'Sair da Conta (Logout)', 
              icon: Icons.logout, 
              color: Colors.red,
              onTap: () => _handleLogout(context),
            ),

            const SizedBox(height: 30),

            // SEÇÃO 3: COMPLIANCE E AJUDA
            _buildSectionTitle('Compliance e Ajuda'),
            _buildSettingsTile(
              context, 
              title: 'Política de Privacidade', 
              icon: Icons.security_outlined, 
              onTap: () {
                // Simulação: Abrir o navegador com o link da política de privacidade
                print('Abrindo Política de Privacidade...');
              },
            ),
            _buildSettingsTile(
              context, 
              title: 'Declaração Ética (LGPD/Saúde)', 
              icon: Icons.info_outline, 
              onTap: () {
                // Exibe o aviso ético do consentimento
                _showEthicalStatement(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper para o título da seção
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey[600],
        ),
      ),
    );
  }

  // Helper para o tile de configuração padrão
  Widget _buildSettingsTile(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap, Color? color}) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: Icon(icon, color: color ?? Theme.of(context).primaryColor),
        title: Text(title, style: TextStyle(color: color ?? Colors.black87)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  // Exibe o aviso ético do AntiBet em um diálogo
  void _showEthicalStatement(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Declaração Ética e de Compliance'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'O AntiBet NÃO é um substituto para terapia clínica ou aconselhamento médico/psicológico.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('Nosso objetivo é fornecer apoio e educação baseada em evidências, mantendo estrita conformidade com a LGPD, garantindo a privacidade e o anonimato dos seus dados.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Entendi'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}