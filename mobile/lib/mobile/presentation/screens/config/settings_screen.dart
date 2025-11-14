import 'package:antibet/core/notifiers/app_config_notifier.dart';
import 'package:antibet/core/notifiers/app_theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta e lê o AppConfigNotifier para obter as configurações atuais
    final configNotifier = context.watch<AppConfigNotifier>();
    final themeNotifier = context.read<AppThemeNotifier>();
    final currentCurrency = configNotifier.currency;

    // Lista de moedas suportadas (simplificada)
    const List<String> supportedCurrencies = ['BRL', 'USD', 'EUR', 'GBP'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Configuração de Tema (Modo Escuro)
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Toggle between light and dark themes.'),
              secondary: const Icon(Icons.dark_mode),
              value: configNotifier.isDarkMode,
              onChanged: (bool newValue) {
                // Atualiza o estado no AppConfigNotifier e no AppThemeNotifier
                configNotifier.setDarkMode(newValue);
                themeNotifier.setThemeMode(newValue ? ThemeMode.dark : ThemeMode.light);
              },
            ),
            const SizedBox(height: 30),

            // 2. Configuração Financeira
            Text(
              'Financial',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Currency'),
              subtitle: const Text('Select your preferred currency for metrics.'),
              trailing: DropdownButton<String>(
                value: supportedCurrencies.contains(currentCurrency) ? currentCurrency : 'BRL',
                items: supportedCurrencies.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    configNotifier.setCurrency(newValue);
                  }
                },
              ),
            ),
            const SizedBox(height: 30),

            // 3. Outras Configurações (Placeholders)
            Text(
              'Other',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About AntiBet'),
              onTap: () {
                // context.go('/about');
              },
            ),
          ],
        ),
      ),
    );
  }
}