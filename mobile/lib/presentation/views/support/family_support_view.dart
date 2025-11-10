import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// O Módulo de Apoio à Família visa fornecer recursos para aqueles que desejam ajudar.

class FamilySupportView extends StatelessWidget {
  const FamilySupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Área de Apoio à Família'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Apoio para Quem Ajuda',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Você não está sozinho(a) nesta jornada. Encontre aqui recursos dedicados a pais, parceiros e amigos.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),

            // 1. Card de Orientação: Como Ajudar Alguém
            _buildGuidanceCard(
              context,
              icon: Icons.group_add,
              title: 'Como Ajudar Alguém',
              subtitle: 'Orientações práticas para lidar com o vício em apostas de um familiar ou amigo.',
              onTap: () => context.go('/support/guidance'),
            ),
            const SizedBox(height: 20),

            // 2. Card de Comunicação: Frases e Mensagens
            _buildGuidanceCard(
              context,
              icon: Icons.chat_bubble_outline,
              title: 'Ferramentas de Conversa',
              subtitle: 'Frases e mensagens prontas para iniciar o diálogo sem brigas e com empatia.',
              onTap: () => context.go('/support/phrases'),
            ),
            const SizedBox(height: 20),

            // 3. Área de Recursos Profissionais (Reiterada)
            const Text(
              'Suporte Profissional e Comunitário',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _buildResourceCard(
              context,
              icon: Icons.people_alt_outlined,
              title: 'Comunidade de Apoio',
              subtitle: 'Acesso a grupos de suporte anônimos e fóruns moderados.', //
              onTap: () => context.go('/community'),
            ),
            const SizedBox(height: 15),

            _buildResourceCard(
              context,
              icon: Icons.medical_services_outlined,
              title: 'Aconselhamento Profissional',
              subtitle: 'Links diretos para CAPS AD e psicólogos parceiros da Inovexa.', //
              onTap: () => context.go('/support/professional'),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // Card para Orientação e Ferramentas (Fluxo Principal)
  Widget _buildGuidanceCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Icon(icon, color: Colors.blue[600], size: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
        trailing: const Icon(Icons.chevron_right, color: Colors.blue),
        onTap: onTap,
      ),
    );
  }

  // Card para Recursos Profissionais (Recursos Externos)
  Widget _buildResourceCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: Icon(icon, color: Colors.teal[600], size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.open_in_new),
        onTap: onTap,
      ),
    );
  }
}