import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Chave para persistência do consentimento
const String _consentKey = 'user_accepted_consent';

class ConsentScreen extends StatelessWidget {
  const ConsentScreen({super.key});

  // Função para simular o aceite e persistir a escolha
  Future<void> _handleAccept(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, true);
    
    // Navega para a próxima etapa do fluxo: Cadastro Inicial (simulado como /register)
    context.go('/register'); 
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Proíbe o pop/swipe back (não há volta antes do consentimento)
      canPop: false, 
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Remove o back button
          backgroundColor: Colors.green[800],
          title: const Text(
            'ESCLARECIMENTO E ACEITE',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(
                  Icons.policy_outlined,
                  color: Colors.green[700],
                  size: 80,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Transparência e Suporte',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                // Texto de esclarecimento
                Text(
                  'Este app é movido por Inteligência Artificial e tem como missão ajudar pessoas a reduzir os danos causados por jogos de aposta online. Não substitui tratamento psicológico ou médico.', 
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 50),
                
                // Botão de Aceite
                ElevatedButton.icon(
                  onPressed: () => _handleAccept(context),
                  icon: const Icon(Icons.check_circle_outline, size: 24),
                  label: const Text(
                    'Li e aceito', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}