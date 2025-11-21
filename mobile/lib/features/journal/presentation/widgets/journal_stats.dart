import 'package:flutter/material.dart';
import 'package:antibet/features/journal/data/models/journal_model.dart';

class JournalStats extends StatelessWidget {
  final JournalModel journal;

  const JournalStats({super.key, required this.journal});

  @override
  Widget build(BuildContext context) {
    // Cálculo simples de ROI (Retorno sobre Investimento) ou Saldo
    // Assumindo que não temos o valor de retorno de cada aposta ainda, apenas se ganhou ou perdeu.
    // Para um MVP real, precisaríamos do valor de retorno (profit) para calcular o saldo real.
    // Por enquanto, exibiremos apenas os totais quantitativos.

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      color: Colors.blueGrey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Resumo do Diário',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  label: 'Investido',
                  value: 'R\$ ${journal.totalInvested.toStringAsFixed(2)}',
                  color: Colors.white,
                ),
                _buildStatItem(
                  label: 'Wins',
                  value: journal.totalWins.toString(),
                  color: Colors.greenAccent,
                ),
                _buildStatItem(
                  label: 'Losses',
                  value: journal.totalLosses.toString(),
                  color: Colors.redAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}