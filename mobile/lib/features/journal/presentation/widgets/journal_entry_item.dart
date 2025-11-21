import 'package:flutter/material.dart';
import 'package:antibet/features/journal/data/models/journal_entry_model.dart';

class JournalEntryItem extends StatelessWidget {
  final JournalEntryModel entry;

  const JournalEntryItem({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final color = entry.isWin ? Colors.green : Colors.red;
    final icon = entry.isWin ? Icons.trending_up : Icons.trending_down;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          title: Text(
            entry.description,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              // Formatação simples da data (DD/MM/AAAA)
              "${entry.date.day.toString().padLeft(2, '0')}/${entry.date.month.toString().padLeft(2, '0')}/${entry.date.year}",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
          trailing: Text(
            'R\$ ${entry.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}