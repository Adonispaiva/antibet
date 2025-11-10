import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Necessário para abrir links/telefone

// Importações dos notifiers e modelos
import '../../notifiers/help_and_alerts_notifier.dart';
import '../../core/domain/help_and_alerts_model.dart';

class HelpAndAlertsView extends StatelessWidget {
  const HelpAndAlertsView({super.key});

  /// Tenta abrir o recurso (URL ou Telefone)
  Future<void> _launchResource(BuildContext context, HelpResourceModel resource) async {
    Uri uri;

    if (resource.type == 'phone') {
      uri = Uri(scheme: 'tel', path: resource.url);
    } else {
      uri = Uri.parse(resource.url);
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir o recurso: ${resource.url}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recursos de Ajuda e Apoio'),
      ),
      body: Consumer<HelpAndAlertsNotifier>(
        builder: (context, notifier, child) {
          switch (notifier.state) {
            case HelpState.loading:
            case HelpState.initial:
              return const Center(child: CircularProgressIndicator());
            
            case HelpState.error:
              return _buildErrorWidget(context, notifier);

            case HelpState.loaded:
              return _buildLoadedList(context, notifier.resources);
          }
        },
      ),
    );
  }
  
  // Widget de exibição de erro
  Widget _buildErrorWidget(BuildContext context, HelpAndAlertsNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning, color: Colors.orange, size: 50),
            const SizedBox(height: 10),
            Text(
              'Erro ao carregar recursos de ajuda: ${notifier.errorMessage}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: notifier.fetchResources, // Tenta recarregar
              child: const Text('Recarregar'),
            ),
          ],
        ),
      ),
    );
  }
  
  // Widget de exibição da lista
  Widget _buildLoadedList(BuildContext context, List<HelpResourceModel> resources) {
    if (resources.isEmpty) {
      return const Center(child: Text('Nenhum recurso de ajuda disponível.'));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index];
        IconData icon;
        
        switch (resource.type) {
          case 'phone':
            icon = Icons.phone;
            break;
          case 'website':
          default:
            icon = Icons.language;
            break;
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: Icon(icon, color: Theme.of(context).primaryColor),
            title: Text(resource.title),
            subtitle: Text(resource.url),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _launchResource(context, resource),
          ),
        );
      },
    );
  }
}