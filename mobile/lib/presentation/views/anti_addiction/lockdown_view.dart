import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:antibet/src/notifiers/lockdown_notifier.dart';

// Esta é a tela que é exibida quando o Módulo de Pânico (Lockdown) é ativado.
// É uma tela de alta criticidade: deve ser informativa e sem rotas de fuga (sem botão de voltar).

class LockdownView extends StatelessWidget {
  const LockdownView({super.key});

  @override
  Widget build(BuildContext context) {
    // Observa o LockdownNotifier para reagir ao status
    final lockdownNotifier = context.watch<LockdownNotifier>();

    return PopScope(
      // Proíbe o pop/swipe back (Android/iOS) na tela de lockdown.
      canPop: false, 
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Remove o back button
          backgroundColor: Colors.red[900],
          title: const Text(
            'INTERVENÇÃO DE PÂNICO',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.lock_rounded,
                  color: Colors.red,
                  size: 120,
                ),
                const SizedBox(height: 30),
                Text(
                  lockdownNotifier.isLockdownActive 
                      ? 'APLICAÇÃO BLOQUEADA' 
                      : 'MÓDULO DE PÂNICO DESATIVADO',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: lockdownNotifier.isLockdownActive ? Colors.red[800] : Colors.green[800],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  lockdownNotifier.isLockdownActive
                      ? 'Você acionou o Botão de Pânico. O acesso à aplicação está restrito para proteger seu progresso. Este bloqueio é inegociável.'
                      : 'O bloqueio foi removido. Você pode retornar à aplicação. Lembre-se de utilizar as ferramentas de Prevenção.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                // Botão de retorno condicional
                if (!lockdownNotifier.isLockdownActive)
                  ElevatedButton.icon(
                    onPressed: () {
                      // Usa a navegação (GoRouter) para retornar à tela principal
                      // O router deve gerenciar o estado e permitir o retorno.
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    icon: const Icon(Icons.check_circle_outline, size: 24),
                    label: const Text(
                      'Retornar à Home',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  )
                else
                  // Se o Lockdown estiver ativo, mostra um timer ou status, mas sem botão de escape imediato.
                  const Text(
                    'STATUS: Ativo. Consulte as regras de desbloqueio.',
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}