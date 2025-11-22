import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importação do Notifier e Modelo
import '../../notifiers/app_config_notifier.dart';

class AppConfigView extends StatelessWidget {
  const AppConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      // O Consumer escuta o Notifier para reagir a mudanças no estado
      body: Consumer<AppConfigNotifier>(
        builder: (context, notifier, child) {
          
          // Função auxiliar para simplificar a chamada de atualização
          void updateConfig({
            bool? isDarkMode,
            bool? areNotificationsEnabled,
            String? languageCode,
          }) {
            notifier.updateConfig(
              isDarkMode: isDarkMode,
              areNotificationsEnabled: areNotificationsEnabled,
              languageCode: languageCode,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              // Título da Seção
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Aparência e Notificações',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              
              // Opção 1: Modo Escuro/Claro
              SwitchListTile(
                title: const Text('Modo Escuro (Dark Mode)'),
                subtitle: const Text('Altera o tema global da aplicação.'),
                secondary: const Icon(Icons.brightness_4),
                value: notifier.isDarkMode,
                onChanged: (newValue) {
                  updateConfig(isDarkMode: newValue);
                },
              ),
              
              const Divider(),

              // Opção 2: Notificações
              SwitchListTile(
                title: const Text('Receber Notificações'),
                subtitle: const Text('Ativa/desativa alertas sobre eventos e notícias.'),
                secondary: const Icon(Icons.notifications_active),
                value: notifier.areNotificationsEnabled,
                onChanged: (newValue) {
                  updateConfig(areNotificationsEnabled: newValue);
                },
              ),
              
              const Divider(),
              
              // TODO: Adicionar Opção de Idioma (Idioma: ${notifier.languageCode.toUpperCase()})
            ],
          );
        },
      ),
    );
  }
}