import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antibet/core/ui/feedback_manager.dart';
import 'package:antibet/features/journal/providers/journal_provider.dart';
import 'package:antibet/features/journal/models/journal_entry_model.dart';

class EditEntryScreen extends ConsumerStatefulWidget {
  final JournalEntryModel entry;

  const EditEntryScreen({super.key, required this.entry});

  @override
  ConsumerState<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends ConsumerState<EditEntryScreen> {
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.entry.amount.toStringAsFixed(2));
    _descriptionController = TextEditingController(text: widget.entry.description);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateEntry() async {
    // Parse explícito para evitar erros de tipo
    final double? newAmount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    
    if (newAmount == null) {
      FeedbackManager.showError(context, 'Valor inválido.');
      return;
    }

    try {
      await ref.read(journalProvider.notifier).updateEntry(
        widget.entry.id,
        amount: newAmount, // Passando double explicitamente
        description: _descriptionController.text.trim(), // Passando String explicitamente
      );

      FeedbackManager.showSuccess(context, 'Aposta atualizada!');
      Navigator.of(context).pop();

    } catch (e) {
      FeedbackManager.showError(context, 'Erro ao atualizar: ${e.toString()}');
    }
  }

  void _deleteEntry() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Aposta'),
        content: const Text('Tem certeza?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(journalProvider.notifier).deleteEntry(widget.entry.id);
        FeedbackManager.showSuccess(context, 'Aposta excluída.');
        Navigator.of(context).pop();
      } catch (e) {
        FeedbackManager.showError(context, 'Erro ao excluir: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Aposta'),
        actions: [
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: _deleteEntry),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Valor (R\$)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _updateEntry,
              child: const Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }
}