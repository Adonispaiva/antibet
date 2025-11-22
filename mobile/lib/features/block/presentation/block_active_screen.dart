import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BlockActiveScreen extends StatefulWidget {
  final int durationMinutes;

  const BlockActiveScreen({
    super.key, 
    this.durationMinutes = 60, // Padrão de 1 hora
  });

  @override
  State<BlockActiveScreen> createState() => _BlockActiveScreenState();
}

class _BlockActiveScreenState extends State<BlockActiveScreen> with SingleTickerProviderStateMixin {
  late Timer _timer;
  late int _remainingSeconds;
  late AnimationController _breathingController;

  @override
  void initState() {
    super.initState();
    // Converte minutos para segundos
    _remainingSeconds = widget.durationMinutes * 60;
    
    // Inicia o cronômetro
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer.cancel();
        // Quando o tempo acaba, permite sair (futuramente)
      }
    });

    // Animação de "Respiração" (Pulsar)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Oculta a barra de status e navegação para imersão total (Modo Kiosk like)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _timer.cancel();
    _breathingController.dispose();
    // Restaura a UI do sistema ao sair
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // PopScope com canPop: false impede o botão "Voltar" do Android
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Modo de Proteção Ativo. Respire fundo.'),
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D), // Fundo muito escuro
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Ícone Pulsante (Foco Visual)
                ScaleTransition(
                  scale: Tween(begin: 0.9, end: 1.1).animate(
                    CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.redAccent.withOpacity(0.1),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_clock,
                      size: 80,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                Text(
                  'MODO FORTALEZA ATIVO',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'Seu acesso a jogos está bloqueado para sua proteção.\nAproveite este tempo para retomar o controle.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Timer Gigante
                Text(
                  _formatTime(_remainingSeconds),
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontFeatures: [const FontFeature.tabularFigures()], // Evita que os números pulem
                    fontWeight: FontWeight.w300,
                  ),
                ),
                
                const SizedBox(height: 8),
                Text(
                  'TEMPO RESTANTE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white30,
                    letterSpacing: 2,
                  ),
                ),
                
                const Spacer(),
                
                // Botão de Emergência (Contato Humano)
                OutlinedButton.icon(
                  onPressed: () {
                    // Lógica para ligar para CVV ou contato de emergência
                  },
                  icon: const Icon(Icons.support_agent, color: Colors.white54),
                  label: const Text('Falar com Suporte Humano'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white54,
                    side: const BorderSide(color: Colors.white24),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Disclaimer
                Text(
                  'Não é possível fechar esta tela até o contador zerar.',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white24),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}