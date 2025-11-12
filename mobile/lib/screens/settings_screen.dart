import 'package:antibet_mobile/notifiers/app_config_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Tela de Configurações do Aplicativo.
///
/// Permite ao usuário gerenciar preferências globais, como tema (Dark Mode)
/// e notificações (futuro).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Observa o Notifier de Configurações
    final appConfig = context.watch<AppConfigNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
          // --- Seção de Aparência ---
          _buildSectionHeader(context, 'Aparência'),
          SwitchListTile(
            title: const Text('Modo Escuro'),
            subtitle: const Text('Ativar ou desativar o tema escuro'),
            value: appConfig.isDarkModeEnabled,
            onChanged: (bool newValue) {
              // Dispara a *ação* no Notifier (usando 'read')
              context.read<AppConfigNotifier>().toggleDarkMode(newValue);
            },
            secondary: const Icon(Icons.brightness_6_outlined),
          ),

          const Divider(),

          // --- Seção de Notificações (Futuro) ---
          _buildSectionHeader(context, 'Notificações'),
          ListTile(
            title: const Text('Gerenciar Notificações'),
            subtitle: const Text('Definir alertas de novas estratégias'),
            leading: const Icon(Icons.notifications_outlined),
            onTap: () {
              // TODO: Navegar para tela de configurações de notificação
            },
            enabled: false, // Desabilitado por enquanto
          ),
        ],
      ),
    );
  }

  /// Helper para construir os cabeçalhos de seção
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}