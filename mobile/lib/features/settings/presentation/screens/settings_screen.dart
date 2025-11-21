import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antibet/features/settings/presentation/providers/user_settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observa o estado das configurações do usuário
    final settingsAsync = ref.watch(userSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Erro ao carregar configurações: ${err.toString().replaceAll('Exception: ', '')}'),
        ),
        data: (settings) {
          // Obtém o notifier para chamar as ações de atualização
          final notifier = ref.read(userSettingsProvider.notifier);

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // --- Opção 1: Tema Escuro ---
              SwitchListTile(
                title: const Text('Modo Escuro'),
                subtitle: const Text('Ativar o tema escuro do aplicativo.'),
                value: settings.isDarkMode,
                onChanged: (bool newValue) {
                  notifier.updateSettings(isDarkMode: newValue);
                  // Nota: A aplicação do tema em tempo real requer que o MaterialApp
                  // ou o main.dart observe esta mudança. Isso é um passo futuro.
                },
                secondary: const Icon(Icons.dark_mode),
              ),
              const Divider(),

              // --- Opção 2: Notificações ---
              SwitchListTile(
                title: const Text('Notificações'),
                subtitle: const Text('Receber alertas sobre o diário e metas.'),
                value: settings.enableNotifications,
                onChanged: (bool newValue) {
                  notifier.updateSettings(enableNotifications: newValue);
                },
                secondary: const Icon(Icons.notifications_active),
              ),
              const Divider(),

              // --- Opção 3: Moeda Preferida ---
              ListTile(
                title: const Text('Moeda Preferida'),
                subtitle: Text('Atualmente: ${settings.preferredCurrency}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Implementar navegação para tela de seleção de moeda
                },
              ),
              const Divider(),
              
              const SizedBox(height: 32),
              
              // Exemplo de como forçar o reset das configurações
              OutlinedButton(
                onPressed: () {
                  notifier.clearSettings();
                },
                child: const Text('RESETAR CONFIGURAÇÕES'),
              ),
            ],
          );
        },
      ),
    );
  }
}