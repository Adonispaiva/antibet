import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Este é o módulo de Ferramentas de Autocontrole e Ajuda Imediata.

class PreventionView extends StatelessWidget {
  const PreventionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ferramentas de Prevenção'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Assuma o Controle',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Aqui você encontra ferramentas práticas para reduzir os estímulos e garantir sua segurança.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),

            // 1. Contador de Tempo sem Apostar (Simulação)
            _buildTimeCounterCard(context),
            const SizedBox(height: 30),

            // 2. Botão de Autoexclusão e Bloqueio
            _buildToolCard(
              icon: Icons.block,
              title: 'Bloqueio e Autoexclusão',
              subtitle: 'Instruções para bloquear contas e sites. Autonomia é a chave.',
              color: Colors.deepOrange,
              onTap: () {
                // Simulação: Navegação para a tela de configurações de bloqueio
                context.go('/settings/autoblock'); 
              },
            ),
            const SizedBox(height: 20),

            // 3. Ferramentas Adicionais (Simulação de Delay Timer/Metas)
            _buildToolCard(
              icon: Icons.timer,
              title: 'Delay Timer e Metas',
              subtitle: 'Ative um contador de foco de 2 minutos antes de tomar decisões impulsivas.',
              color: Colors.blueGrey,
              onTap: () {
                // Simulação: Iniciar o Delay Timer
              },
            ),
            const SizedBox(height: 40),

            const Divider(),
            const SizedBox(height: 20),

            // 4. Ajuda Profissional (Emergência)
            const Text(
              'Ajuda Profissional e Emergência',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            _buildEmergencyContact(
              icon: Icons.phone_in_talk,
              title: 'Ligue CVV (Centro de Valorização da Vida)',
              subtitle: 'Fale com alguém imediatamente. Ajuda 24h.',
              color: Colors.indigo,
              onTap: () {
                // Simulação: Abrir link ou discador (Ex: Uri.parse('tel:188'))
              },
            ),
            _buildEmergencyContact(
              icon: Icons.local_hospital,
              title: 'Recursos CAPS AD',
              subtitle: 'Encontre clínicas e centros de apoio psicossocial próximos.',
              color: Colors.teal,
              onTap: () {
                // Simulação: Navegar para mapa/lista de recursos CAPS AD
              },
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
  
  // Widget para o Contador de Tempo (Estilo NA)
  Widget _buildTimeCounterCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dias de Força',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '125', // Simulação de Dias Sem Apostar
                  style: TextStyle(fontSize: 60, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32)), // Verde Escuro
                ),
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.green[700],
                  size: 60,
                ),
              ],
            ),
            const Text(
              'dias sem apostar. Grande vitória!',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
  
  // Widget padrão para ferramentas
  Widget _buildToolCard({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  // Widget para contatos de emergência
  Widget _buildEmergencyContact({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 28),
        label: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(subtitle, style: const TextStyle(fontSize: 12)),
          ],
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 80),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      ),
    );
  }
}