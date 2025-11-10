import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Constante para a cor do progresso/sucesso (Verde Escuro)
const Color _progressColor = Color(0xFF2E7D32); 
// Constante para a cor do Fundo (Cinza Claro)
const Color _backgroundColor = Color(0xFFF7F8F9); 

class FinanceView extends StatelessWidget {
  const FinanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Financeiro'), //
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      backgroundColor: _backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Suas Conquistas Financeiras',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Veja o dinheiro que você está economizando ao manter o controle.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),

            // 1. Card Principal: Economia Acumulada (Métrica Chave)
            _buildEconomyCard(context),
            const SizedBox(height: 20),
            
            // 2. Card de Métricas de Progresso
            Row(
              children: [
                Expanded(child: _buildMetricCard(
                  icon: Icons.calendar_today,
                  title: 'Dias sem Apostar', //
                  value: '125', // Simulação
                  unit: 'Dias',
                  color: Colors.blueAccent,
                )),
                const SizedBox(width: 16),
                Expanded(child: _buildMetricCard(
                  icon: Icons.lightbulb_outline,
                  title: 'Metas Alcançadas',
                  value: '3', // Simulação
                  unit: 'Metas',
                  color: Colors.orange,
                )),
              ],
            ),
            const SizedBox(height: 30),

            // 3. Simulador de Oportunidade Perdida
            _buildOpportunitySimulatorCard(context),
            
            const SizedBox(height: 30),
            
            // 4. Integração Open Banking (Avançado)
            _buildOpenBankingCTA(context),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // Card para a Métrica Principal (Economia Acumulada)
  Widget _buildEconomyCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: _progressColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seu Saldo AntiBet é de:',
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'R\$ 7.345,50', // Simulação de Economia
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Icon(Icons.trending_up, color: Colors.white, size: 48),
              ],
            ),
            const SizedBox(height: 5),
            const Text(
              '* Estimativa baseada em seus padrões anteriores de aposta.',
              style: TextStyle(fontSize: 12, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  // Card para métricas secundárias (dias, metas)
  Widget _buildMetricCard({required IconData icon, required String title, required String value, required String unit, required Color color}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(width: 4),
                Text(unit, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Card Simulador de Oportunidade Perdida
  Widget _buildOpportunitySimulatorCard(BuildContext context) {
    return Card(
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Icon(Icons.money_off, color: Colors.red[700], size: 40),
        title: const Text('Simulador de Oportunidade Perdida', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Veja o que você poderia ter comprado ou investido com o valor total das suas perdas.'),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          // Simulação: Navegação para o simulador de investimento
          context.go('/finance/simulator');
        },
      ),
    );
  }

  // CTA para Conexão Open Banking (Futura implementação)
  Widget _buildOpenBankingCTA(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.credit_card, color: Colors.blue[700]),
          const SizedBox(width: 15),
          const Expanded(
            child: Text(
              'Conecte seu banco (Open Banking) para dados em tempo real e mais precisos.',
              style: TextStyle(fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: () {
              // Simulação: Navegação para a tela de Open Banking
              context.go('/finance/openbanking');
            },
            child: Text('Conectar', style: TextStyle(color: Colors.blue[700])),
          ),
        ],
      ),
    );
  }
}