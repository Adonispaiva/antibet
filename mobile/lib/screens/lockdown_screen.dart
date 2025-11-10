import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Necessário para formatação de data/hora (Adicionar ao pubspec.yaml)

import 'package:antibet_app/notifiers/lockdown_notifier.dart';

/// Tela exibida pelo AppRouter quando o usuário está em Lockdown (Bloqueio).
class LockdownScreen extends StatelessWidget {
  const LockdownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta o estado de bloqueio para reagir ao tempo restante
    final notifier = context.watch<LockdownNotifier>();
    final theme = Theme.of(context);

    // Determina o texto de tempo restante
    String timeRemainingText;
    if (notifier.lockdownEndTime != null) {
      final endTime = notifier.lockdownEndTime!;
      final formatter = DateFormat('dd/MM/yyyy HH:mm:ss');
      timeRemainingText = 'Seu bloqueio termina em: ${formatter.format(endTime.toLocal())}.';
    } else {
      timeRemainingText = 'O bloqueio está ativo, mas o tempo de término não foi definido.';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bloqueio Ativo (Missão Anti-Vício)'),
        automaticallyImplyLeading: false, // Bloqueia o retorno
        backgroundColor: theme.colorScheme.error,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.security_update_disabled_rounded,
                size: 80,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 32),
              
              Text(
                'ACESSO BLOQUEADO POR SEGURANÇA',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              
              Text(
                'Este recurso foi desativado temporariamente para proteger você contra comportamentos de risco, conforme as regras da Missão Anti-Vício.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),

              // Tempo Restante
              Text(
                timeRemainingText,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 40),

              // Botão de Emergência (Botão de Pânico)
              // Este botão serve para testar a ativação, mas o Router deve proteger.
              ElevatedButton.icon(
                onPressed: () {
                  // Simula a ativação do Botão de Pânico (para fins de desenvolvimento)
                  notifier.activateLockdown(); 
                },
                icon: const Icon(Icons.lock_clock),
                label: const Text('Ativar 24h de Bloqueio (Debug)'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: theme.colorScheme.onError,
                  backgroundColor: theme.colorScheme.error,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}