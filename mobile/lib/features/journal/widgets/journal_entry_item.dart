import 'package:flutter/material.dart';
import 'package:antibet/features/journal/models/journal_entry_model.dart';
import 'package:antibet/features/journal/screens/edit_entry_screen.dart';

class JournalEntryItem extends StatelessWidget {
  final JournalEntryModel entry;

  const JournalEntryItem({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    // Determine a cor com base no status ou tipo (aqui simplificado para positivo/negativo)
    final isLoss = entry.amount < 0;
    final amountColor = isLoss ? Colors.redAccent : Colors.green;

    // Utilize um ListTile para estrutura e GestureDetector para o Tap (conforme navegação planejada)
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      elevation: 1,
      child: ListTile(
        // Navegação para a tela de edição
        onTap: () {
          // Navegação via Tap no Item para EditEntryScreen, conforme o relatório técnico anterior
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditEntryScreen(entry: entry),
            ),
          );
        },
        // Ícone de prefixo
        leading: Icon(
          isLoss ? Icons.trending_down : Icons.trending_up,
          color: amountColor,
        ),
        
        // Título: Descrição
        title: Text(
          entry.description.isNotEmpty ? entry.description : 'Aposta Sem Descrição',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        
        // Subtítulo: Data
        subtitle: Text(
          '${entry.date.day.toString().padLeft(2, '0')}/${entry.date.month.toString().padLeft(2, '0')}/${entry.date.year}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        
        // Trailing: Valor
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'R\$ ${entry.amount.abs().toStringAsFixed(2)}',
              style: TextStyle(
                color: amountColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            // Espaço para um status ou tipo de aposta, se necessário
          ],
        ),
      ),
    );
  }
}