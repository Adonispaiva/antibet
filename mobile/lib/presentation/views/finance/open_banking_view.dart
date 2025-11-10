import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:antibet/src/core/notifiers/open_banking_notifier.dart';

class OpenBankingView extends StatelessWidget {
  const OpenBankingView({super.key});

  Future<void> _handleConnect(BuildContext context, OpenBankingNotifier notifier) async {
    final success = await notifier.connectBank();
    if (context.mounted && success) {
      // Simulação de navegação após sucesso: volta para o painel principal para ver os dados
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conexão bem-sucedida! Seus dados financeiros foram carregados.')),
      );
      context.go('/finance'); 
    } else if (context.mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha na conexão. Tente novamente ou verifique suas credenciais.', style: TextStyle(color: Colors.red))),
      );
    }
  }

  Future<void> _handleDisconnect(BuildContext context, OpenBankingNotifier notifier) async {
    await notifier.disconnectBank();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conexão bancária revogada com sucesso.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<OpenBankingNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conexão Open Banking'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Icon(Icons.account_balance_wallet, size: 80, color: Color(0xFF283593)), // Azul escuro
            const SizedBox(height: 30),

            const Text(
              'Rastreie Suas Perdas Reais',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Aviso de Privacidade
            _buildPrivacyCard(),
            const SizedBox(height: 40),

            // Status da Conexão
            _buildConnectionStatus(context, notifier),
            const SizedBox(height: 30),

            // Botões de Ação
            if (notifier.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (!notifier.isConnected)
              ElevatedButton.icon(
                onPressed: () => _handleConnect(context, notifier),
                icon: const Icon(Icons.link, color: Colors.white),
                label: const Text('Conectar Minha Conta Bancária'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () => _handleDisconnect(context, notifier),
                icon: const Icon(Icons.unlink, color: Colors.white),
                label: const Text('Desconectar / Revogar Acesso'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Card de Aviso de Privacidade e Segurança
  Widget _buildPrivacyCard() {
    return Card(
      elevation: 2,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.security, color: Colors.blue[700], size: 30),
            const SizedBox(width: 15),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Segurança e LGPD',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Usamos criptografia ponta a ponta e anonimato. Seu acesso é apenas para cálculo de perdas e não pode realizar transações. Conformidade total com a LGPD.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Exibe o status atual da conexão
  Widget _buildConnectionStatus(BuildContext context, OpenBankingNotifier notifier) {
    final bool isConnected = notifier.isConnected;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status Atual:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(
              isConnected ? Icons.check_circle : Icons.error,
              color: isConnected ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 10),
            Text(
              isConnected ? 'Conectado e Dados Carregados' : 'Desconectado',
              style: TextStyle(
                color: isConnected ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}