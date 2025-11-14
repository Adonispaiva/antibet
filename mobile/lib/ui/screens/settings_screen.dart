import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:antibet/core/notifiers/app_config_notifier.dart';
import 'package:antibet/core/notifiers/auth_notifier.dart';

/// Tela responsável por gerenciar as configurações do aplicativo e do usuário
/// (Tab 3 da Dashboard).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Consome os notifiers necessários
    final appConfig = Provider.of<AppConfigNotifier>(context);
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // Seção: Aparência
          _buildSectionTitle(context, 'Aparência'),
          SwitchListTile(
            title: const Text('Tema Escuro'),
            subtitle: const Text('Alternar entre modo claro e escuro'),
            value: appConfig.isDarkMode,
            onChanged: (bool value) {
              appConfig.setDarkMode(value);
            },
            secondary: Icon(appConfig.isDarkMode ? Icons.nightlight_round : Icons.wb_sunny),
          ),
          
          const Divider(),

          // Seção: Notificações
          _buildSectionTitle(context, 'Notificações'),
          SwitchListTile(
            title: const Text('Habilitar Notificações'),
            subtitle: const Text('Alertas de desempenho e lembretes'),
            value: appConfig.areNotificationsEnabled,
            onChanged: (bool value) {
              appConfig.toggleNotifications(value);
            },
            secondary: const Icon(Icons.notifications_outlined),
          ),
          
          const Divider(),

          // Seção: Conta
          _buildSectionTitle(context, 'Conta'),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Editar Perfil'),
            onTap: () {
              // Navegar para a tela de perfil (a ser criada)
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Alterar Senha'),
            onTap: () {
              // Navegar para a tela de alteração de senha (a ser criada)
            },
          ),
          
          const SizedBox(height: 40),
          
          // Botão de Logout
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                // Chama o método de logout do notifier
                authNotifier.logout();
                // O AuthCheckerScreen no app_routes.dart irá tratar
                // a navegação de volta para a tela de Login.
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sair da Conta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper para construir os títulos de seção.
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}