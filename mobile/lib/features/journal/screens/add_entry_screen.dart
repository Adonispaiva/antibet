import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antibet/core/ui/feedback_manager.dart'; // Importação do FeedbackManager
import 'package:antibet/features/journal/providers/journal_provider.dart';

// O widget é convertido para ConsumerWidget para acessar o ref do Riverpod
class AddEntryScreen extends ConsumerWidget {
  const AddEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    // Função de submissão assíncrona
    void submitEntry() async {
      final double? amount = double.tryParse(amountController.text);
      
      if (amount == null || amount <= 0) {
        FeedbackManager.showError(context, 'O valor da aposta deve ser válido.');
        return;
      }

      // Adiciona a lógica de loading visual (opcional, mas bom para UX)
      // Geralmente, isso envolveria um StateNotifier que muda o estado para loading.
      // Aqui, vamos direto à chamada da API e ao feedback.

      try {
        await ref.read(journalProvider.notifier).createEntry(
          amount: amount,
          description: descriptionController.text.trim(),
        );

        // Sucesso: Exibe o feedback e retorna à tela anterior
        FeedbackManager.showSuccess(context, 'Aposta de R\$ ${amount.toStringAsFixed(2)} registrada com sucesso!');
        Navigator.of(context).pop();

      } catch (e) {
        // Erro: Exibe feedback de erro
        FeedbackManager.showError(context, 'Falha ao registrar aposta: ${e.toString().split(':').last.trim()}');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Aposta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Valor da Aposta (R\$)',
                key: Key('amount_field'),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              keyboardType: TextInputType.text,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descrição/Observação (Opcional)',
                key: Key('description_field'),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: submitEntry,
              icon: const Icon(Icons.save),
              label: const Text('Salvar'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // Botão de largura total
              ),
            ),
          ],
        ),
      ),
    );
  }
}